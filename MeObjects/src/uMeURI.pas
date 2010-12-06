
{ Summary: Represents the Uniform Resource Identifier object. }
{ Description
 An instance of this class represents a URI reference as defined by RFC 2396(http://www.ietf.org/rfc/rfc2396.txt): Uniform Resource Identifiers (URI): Generic Syntax, amended by RFC 2732: Format for Literal IPv6 Addresses in URLs and with the minor deviations noted below. This class provides constructors for creating URI instances from their components or by parsing their string forms, methods for accessing the various components of an instance, and methods for normalizing, resolving, and relativizing URI instances. Instances of this class are immutable.

URI syntax and components
At the highest level a URI reference (hereinafter simply "URI") in string form has the syntax

    [scheme:]scheme-specific-part[#fragment] 

where square brackets [...] delineate optional components and the characters : and # stand for themselves.

An absolute URI specifies a scheme; a URI that is not absolute is said to be relative. URIs are also classified according to whether they are opaque or hierarchical.

An opaque URI is an absolute URI whose scheme-specific part does not begin with a slash character ('/'). Opaque URIs are not subject to further parsing. Some examples of opaque URIs are:

    mailto:java-net@java.sun.com	
    news:comp.lang.java	
    urn:isbn:096139210x

A hierarchical URI is either an absolute URI whose scheme-specific part begins with a slash character, or a relative URI, that is, a URI that does not specify a scheme. Some examples of hierarchical URIs are:

    http://java.sun.com/j2se/1.3/
    docs/guide/collections/designfaq.html#28 ../../../demo/jfc/SwingSet2/src/SwingSet2.java file:///~/calendar 

A hierarchical URI is subject to further parsing according to the syntax

    [scheme:][//authority][path][?query][#fragment] 

where the characters :, /, ?, and # stand for themselves. The scheme-specific part of a hierarchical URI consists of the characters between the scheme and fragment components.

The authority component of a hierarchical URI is, if specified, either server-based or registry-based. A server-based authority parses according to the familiar syntax

    [user-info@]host[:port] 

where the characters @ and : stand for themselves. Nearly all URI schemes currently in use are server-based. An authority component that does not parse in this way is considered to be registry-based.

The path component of a hierarchical URI is itself said to be absolute if it begins with a slash character ('/'); otherwise it is relative. The path of a hierarchical URI that is either absolute or specifies an authority is always absolute.

All told, then, a URI instance has the following nine components:

    Component              Type
    scheme                 String
    scheme-specific-part   String
    authority              String
    user-info              String
    host                   String
    port                   int
    path                   String
    query                  String
    fragment               String

In a given instance any particular component is either undefined or defined with a distinct value. Undefined string components are represented by null, while undefined integer components are represented by -1. A string component may be defined to have the empty string as its value; this is not equivalent to that component being undefined.

Whether a particular component is or is not defined in an instance depends upon the type of the URI being represented. An absolute URI has a scheme component. An opaque URI has a scheme, a scheme-specific part, and possibly a fragment, but has no other components. A hierarchical URI always has a path (though it may be empty) and a scheme-specific-part (which at least contains the path), and may have any of the other components. If the authority component is present and is server-based then the host component will be defined and the user-information and port components may be defined.
Operations on URI instances
The key operations supported by this class are those of normalization, resolution, and relativization.

Normalization is the process of removing unnecessary "." and ".." segments from the path component of a hierarchical URI. Each "." segment is simply removed. A ".." segment is removed only if it is preceded by a non-".." segment. Normalization has no effect upon opaque URIs.

Resolution is the process of resolving one URI against another, base URI. The resulting URI is constructed from components of both URIs in the manner specified by RFC 2396, taking components from the base URI for those not specified in the original. For hierarchical URIs, the path of the original is resolved against the path of the base and then normalized. The result, for example, of resolving

    docs/guide/collections/designfaq.html#28          (1) 

against the base URI http://java.sun.com/j2se/1.3/ is the result URI

    http://java.sun.com/j2se/1.3/docs/guide/collections/designfaq.html#28 

Resolving the relative URI

    ../../../demo/jfc/SwingSet2/src/SwingSet2.java    (2) 

against this result yields, in turn,

    http://java.sun.com/j2se/1.3/demo/jfc/SwingSet2/src/SwingSet2.java 

Resolution of both absolute and relative URIs, and of both absolute and relative paths in the case of hierarchical URIs, is supported. Resolving the URI file:///~calendar against any other URI simply yields the original URI, since it is absolute. Resolving the relative URI (2) above against the relative base URI (1) yields the normalized, but still relative, URI

    demo/jfc/SwingSet2/src/SwingSet2.java 

Relativization, finally, is the inverse of resolution: For any two normalized URIs u and v,

    u.relativize(u.resolve(v)).equals(v)  and
    u.resolve(u.relativize(v)).equals(v)  .

This operation is often useful when constructing a document containing URIs that must be made relative to the base URI of the document wherever possible. For example, relativizing the URI

    http://java.sun.com/j2se/1.3/docs/guide/index.html 

against the base URI

    http://java.sun.com/j2se/1.3 

yields the relative URI docs/guide/index.html.
Character categories
RFC 2396 specifies precisely which characters are permitted in the various components of a URI reference. The following categories, most of which are taken from that specification, are used below to describe these constraints:

    alpha 	The US-ASCII alphabetic characters, 'A' through 'Z' and 'a' through 'z'
    digit 	The US-ASCII decimal digit characters, '0' through '9'
    alphanum 	All alpha and digit characters
    unreserved     	All alphanum characters together with those in the string "_-!.~'()*"
    punct 	The characters in the string ",;:$&+="
    reserved 	All punct characters together with those in the string "?/[]@"
    escaped 	Escaped octets, that is, triplets consisting of the percent character ('%') followed by two hexadecimal digits ('0'-'9', 'A'-'F', and 'a'-'f')
    other 	The Unicode characters that are not in the US-ASCII character set, are not control characters (according to the Character.isISOControl method), and are not space characters (according to the Character.isSpaceChar method)  (Deviation from RFC 2396, which is limited to US-ASCII)

The set of all legal URI characters consists of the unreserved, reserved, escaped, and other characters.
Escaped octets, quotation, encoding, and decoding
RFC 2396 allows escaped octets to appear in the user-info, path, query, and fragment components. Escaping serves two purposes in URIs:

    *      To encode non-US-ASCII characters when a URI is required to conform strictly to RFC 2396 by not containing any other characters.
    *      To quote characters that are otherwise illegal in a component. The user-info, path, query, and fragment components differ slightly in terms of which characters are considered legal and illegal.

These purposes are served in this class by three related operations:

    *      A character is encoded by replacing it with the sequence of escaped octets that represent that character in the UTF-8 character set. The Euro currency symbol ('\u20AC'), for example, is encoded as "%E2%82%AC". (Deviation from RFC 2396, which does not specify any particular character set.)
    *      An illegal character is quoted simply by encoding it. The space character, for example, is quoted by replacing it with "%20". UTF-8 contains US-ASCII, hence for US-ASCII characters this transformation has exactly the effect required by RFC 2396.
    *      A sequence of escaped octets is decoded by replacing it with the sequence of characters that it represents in the UTF-8 character set. UTF-8 contains US-ASCII, hence decoding has the effect of de-quoting any quoted US-ASCII characters as well as that of decoding any encoded non-US-ASCII characters. If a decoding error occurs when decoding the escaped octets then the erroneous octets are replaced by '\uFFFD', the Unicode replacement character.

These operations are exposed in the constructors and methods of this class as follows:

    *      The single-argument constructor requires any illegal characters in its argument to be quoted and preserves any escaped octets and other characters that are present.
    *      The multi-argument constructors quote illegal characters as required by the components in which they appear. The percent character ('%') is always quoted by these constructors. Any other characters are preserved.
    *      The getRawUserInfo, getRawPath, getRawQuery, getRawFragment, getRawAuthority, and getRawSchemeSpecificPart methods return the values of their corresponding components in raw form, without interpreting any escaped octets. The strings returned by these methods may contain both escaped octets and other characters, and will not contain any illegal characters.
    *      The getUserInfo, getPath, getQuery, getFragment, getAuthority, and getSchemeSpecificPart methods decode any escaped octets in their corresponding components. The strings returned by these methods may contain both other characters and illegal characters, and will not contain any escaped octets.
    *      The toString method returns a URI string with all necessary quotation but which may contain other characters.
    *      The toASCIIString method returns a fully quoted and encoded URI string that does not contain any other characters.

Identities
For any URI u, it is always the case that

    new URI(u.toString()).equals(u) . 

For any URI u that does not contain redundant syntax such as two slashes before an empty authority (as in file:///tmp/ ) or a colon following a host name but no port (as in http://java.sun.com: ), and that does not encode characters except those that must be quoted, the following identities also hold:

    new URI(u.getScheme(),
            u.getSchemeSpecificPart(),
            u.getFragment())
    .equals(u) 

in all cases,

    new URI(u.getScheme(),
            u.getUserInfo(), u.getAuthority(),
            u.getPath(), u.getQuery(),
            u.getFragment())
    .equals(u) 

if u is hierarchical, and

    new URI(u.getScheme(),
            u.getUserInfo(), u.getHost(), u.getPort(),
            u.getPath(), u.getQuery(),
            u.getFragment())
    .equals(u) 

if u is hierarchical and has either no authority or a server-based authority.
URIs, URLs, and URNs
A URI is a uniform resource identifier while a URL is a uniform resource locator. Hence every URL is a URI, abstractly speaking, but not every URI is a URL. This is because there is another subcategory of URIs, uniform resource names (URNs), which name resources but do not specify how to locate them. The mailto, news, and isbn URIs shown above are examples of URNs.

The conceptual distinction between URIs and URLs is reflected in the differences between this class and the URL class.

An instance of this class represents a URI reference in the syntactic sense defined by RFC 2396. A URI may be either absolute or relative. A URI string is parsed according to the generic syntax without regard to the scheme, if any, that it specifies. No lookup of the host, if any, is performed, and no scheme-dependent stream handler is constructed. Equality, hashing, and comparison are defined strictly in terms of the character content of the instance. In other words, a URI instance is little more than a structured string that supports the syntactic, scheme-independent operations of comparison, normalization, resolution, and relativization.

An instance of the URL class, by contrast, represents the syntactic components of a URL together with some of the information required to access the resource that it describes. A URL must be absolute, that is, it must always specify a scheme. A URL string is parsed according to its scheme. A stream handler is always established for a URL, and in fact it is impossible to create a URL instance for a scheme for which no handler is available. Equality and hashing depend upon both the scheme and the Internet address of the host, if any; comparison is not defined. In other words, a URL is a structured string that supports the syntactic operation of resolution as well as the network I/O operations of looking up the host and opening a connection to the specified resource.

See Also:
    RFC 2279: UTF-8, a transformation format of ISO 10646,
    RFC 2373: IPv6 Addressing Architecture,
    RFC 2396: Uniform Resource Identifiers (URI): Generic Syntax,
    RFC 2732: Format for Literal IPv6 Addresses in URLs,

  License:
    * The contents of this file are released under a dual \license, and
    * you may choose to use it under either the Mozilla Public License
    * 1.1 (MPL 1.1, available from http://www.mozilla.org/MPL/MPL-1.1.html)
    * or the GNU Lesser General Public License 2.1 (LGPL 2.1, available from
    * http://www.opensource.org/licenses/lgpl-license.php).
    * Software distributed under the License is distributed on an "AS
    * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
    * implied. See the License for the specific language governing
    * rights and limitations under the \license.
    * The Original Code is $RCSfile: uMeURI.pas,v $.
    * The Initial Developers of the Original Code are Indy Project.
    * Portions created by Chad Z. Hower and the Indy Pit Crew. is Copyright (C) 1993-2004
    * Portions created by Riceball LEE is Copyright (C) 2006-2008
    * All rights reserved.

    * Contributor(s):
      Chad Z. Hower and the Indy Pit Crew
      ARybin
      czhower
      SPerry
      GGrieve
      BGooijen
      SGrobety
      JPMugaas
      Peter Mee
      Doychin Bondzhev
}
{ Chinese:
��ʾһ��ͳһ��Դ��ʶ�� (URI) ���á�

���������ᵽ��һЩϸ΢��֮ͬ���⣬�����ʵ������һ�� URI ���ã����������ĵ��ж��壺RFC 2396: Uniform Resource Identifiers (URI):Generic Syntax���ڴ��ļ��ж��������ֽ�����������RFC 2732:Format for Literal IPv6 Addresses in URLs������ֵ IPv6 ��ַ��ʽ��֧�� scope_ids��scope_ids ���﷨���÷��ڴ˴������������ṩ�����ڴ�����ɲ��ֻ�ͨ���������ַ�����ʽ���� URI ʵ���Ĺ��췽�������ڷ���ʵ���ĸ�����ͬ��ɲ��ֵķ������Լ����ڶ� URI ʵ�����й淶������������Ի��ķ����������ʵ�����ɱ䡣
URI �﷨����ɲ���
����߼����ϣ��ַ�����ʽ�� URI ���ã����¼�дΪ "URI"���﷨����

    [scheme:]scheme-specific-part[#fragment] 

���У������� [...] ����������ѡ��ɲ��֣��ַ� : �� # ������������

���� URI ָ���˷��� (scheme)���Ǿ��Ե� URI ��Ϊ��� URI��URI �����Ը������Ƿ�Ϊ��͸���� ��ֲ�� ���з��ࡣ

��͸�� URI Ϊ���� URI�����ض��ڷ����Ĳ��ֲ�����б���ַ� ('/') ��ʼ����͸�� URI �޷����н�һ�������������ǲ�͸�� URI ��һЩʾ����

    mailto:java-net@java.sun.com	
    news:comp.lang.java	
    urn:isbn:096139210x

�ֲ� URI ����Ϊ���� URI�����ض��ڷ����Ĳ�����б���ַ���ʼ��������Ϊ��� URI������ָ�������� URI�������Ƿֲ� URI ��һЩʾ����

    http://java.sun.com/j2se/1.3/
    docs/guide/collections/designfaq.html#28
    ../../../demo/jfc/SwingSet2/src/SwingSet2.java
    file:///~/calendar 

�ֲ� URI ��Ҫ����������﷨���н�һ���Ľ���

    [scheme:][//authority][path][?query][#fragment] 

���У�:��/��? �� # �������������ֲ� URI ���ض��ڷ����Ĳ��ְ���������Ƭ�β���֮����ַ���

�ֲ� URI ����Ȩ��ɲ��֣����ָ����Ϊ���ڷ������� �����ע���ġ����ڷ���������Ȩ��������������֪���﷨���н�����

    [user-info@]host[:port] 

���У��ַ� @ �� : ������������������ǰʹ�õ����� URI �������ǻ��ڷ������ġ����ܲ������ַ�ʽ��������Ȩ��ɲ��ֱ���Ϊ����ע���ġ�

����ֲ� URI ��·����ɲ�����б���ַ� ('/') ��ʼ����ƴ� URI ����Ϊ���Եģ�������Ϊ��Եġ��ֲ� URI ����Ϊ���Եģ�����ָ������Ȩ��·������ʼ��Ϊ���Եġ�

����������URI ʵ���������¾Ÿ���ɲ��֣�

    ��ɲ���	����
    ����	String
    �ض��ڷ����Ĳ���	String
    ��Ȩ	String
    �û���Ϣ	String
    ����	String
    �˿�	int
    ·��	String
    ��ѯ	String
    Ƭ��	String

�ڸ���ʵ���У��κ�������ɲ��ֶ�����Ϊδ����ģ�����Ϊ�Ѷ���ģ������в�ͬ��ֵ��δ������ַ�����ɲ����� null ��ʾ��δ�����������ɲ����� -1 ��ʾ���Ѷ�����ַ�����ɲ��ֵ�ֵ����Ϊ���ַ���������δ�������ɲ��ֲ���Ч��

ʵ�����ض�����ɲ������Ѷ���Ļ���δ�����ȡ����������� URI ���͡����� URI ���з�����ɲ��֡���͸���� URI ����һ��������һ���ض��ڷ����Ĳ��֣��Լ����ܻ���һ��Ƭ�Σ�����û��������ɲ��֡��ֲ� URI ������һ��·�������ܿ���Ϊ�գ���һ���ض��ڷ����Ĳ��֣������ٰ���һ��·�����������԰����κ�������ɲ��֡��������Ȩ��ɲ����������ǻ��ڷ������ģ���������ɲ��ֽ������壬Ҳ�п��ܶ����û���Ϣ�Ͷ˿���ɲ��֡�
��� URI ʵ��������
����֧�ֵ���Ҫ�����й淶�������� ����Ի� ���㡣

�淶�� �ǽ��ֲ� URI ��·����ɲ����еĲ���Ҫ�� "." �� ".." �����Ƴ��Ĺ��̡�ÿ�� "." ���ֶ������Ƴ���".." ����Ҳ���Ƴ���������ǰ����һ���� ".." ���֡��淶���Բ�͸�� URI �������κ�Ч����

���� �Ǹ�����һ������ URI ����ĳ�� URI �Ĺ��̡��õ��� URI ������ URI ��ɲ��ֹ��죬���췽ʽ�� RFC 2396 ָ�����ӻ��� URI ȡ��ԭʼ URI ��δָ������ɲ��֡����ڷֲ� URI��ԭʼ��·�����ݻ���·�����н�����Ȼ����й淶�������磬�������� URI

    docs/guide/collections/designfaq.html#28          (1) 

���ݻ��� URI http://java.sun.com/j2se/1.3/ ���������Ϊ URI

    http://java.sun.com/j2se/1.3/docs/guide/collections/designfaq.html#28 

������� URI

    ../../../demo/jfc/SwingSet2/src/SwingSet2.java    (2) 

���ݴ˽��Ӧ����

    http://java.sun.com/j2se/1.3/demo/jfc/SwingSet2/src/SwingSet2.java 

֧�ֶԾ��Ժ���� URI���Լ��ֲ� URI �ľ��Ժ����·���Ľ����������κ����� URI �� URI file:///~calendar ���н���ֻ������ԭʼ�� URI����Ϊ���Ǿ���·����������Ի��� URI (1) ������� URI (2) �����ɹ淶�ĵ���Ȼ����Ե� URI

    demo/jfc/SwingSet2/src/SwingSet2.java 

�����Ի� �ǽ���������̣������κ������淶�� URI u �� v��

    u.relativize(u.resolve(v)).equals(v)  ��
    u.resolve(u.relativize(v)).equals(v)��

������������ĳ��Ϸǳ����ã�����һ������ URI ���ĵ����� URI ���뾡�����Ǹ����ĵ��Ļ��� URI ��������� URI�����磬��Ի� URI

    http://java.sun.com/j2se/1.3/docs/guide/index.html 

���ݻ��� URI

    http://java.sun.com/j2se/1.3 

��������� URI docs/guide/index.html��
�ַ�����
RFC 2396 ��ȷָ�� URI �����еĸ�����ͬ��ɲ�������ʹ�õ��ַ������·���󲿷�ȡ�Ըù淶����ЩԼ�����÷��������£�

    alpha 	US-ASCII ��ĸ�ַ���'A' �� 'Z' �Լ� 'a' �� 'z'
    digit 	US-ASCII ʮ�������ַ���'0' �� '9'
    alphanum 	���� alpha �� digit �ַ�
    unreserved     	���� alphanum �ַ����ַ��� "_-!.~'()*" �а������ַ�
    punct 	�ַ��� ",;:$&+=" �а������ַ�
    reserved 	���� punct �ַ����ַ��� "?/[]@" �а������ַ�
    escaped 	ת���λ�飬����������ϣ��ٷֺ� ('%') �������ʮ����������'0'-'9'��'A'-'F' �� 'a'-'f'��
    other 	δ������ US-ASCII �ַ����е� Unicode �ַ����ǿ����ַ������� Character.isISOControl �����������Ҳ��ǿո��ַ������� Character.isSpaceChar ���������� RFC 2396 ��Щ���룬RFC 2396 ����Ϊ US-ASCII��

ȫ���Ϸ� URI �ַ������� unreserved��reserved��escaped �� other �ַ���
ת���λ�顢���á�����ͽ���
RFC 2396 �����û���Ϣ��·������ѯ��Ƭ����ɲ����а���ת���λ�顣ת���� URI ��ʵ������Ŀ�ģ�

    *      ��Ҫ�� URI ���ܰ����κ� other �ַ����ϸ����� RFC 2396 ʱ����Ҫ�Է� US-ASCII �ַ����б��롣
    *      Ҫ���� ��ɲ����еķǷ��ַ����û���Ϣ��·������ѯ��Ƭ����ɲ������ж���Щ�ַ��Ϸ���Щ�ַ��Ƿ������в�ͬ��

�ڴ�������������ص�����ʵ����������Ŀ�ģ�

    *      �ַ��ı��� ��ʽ�ǣ��ô�����ַ��� UTF-8 �ַ����е��ַ���ת���λ������ȡ�����ַ������磬ŷԪ���� ('\u20AC') �����Ϊ "%E2%82%AC"������ RFC 2396 ��Щ���룬RFC 2396 δָ���κ������ַ�������
    *      �Ƿ��ַ�ͨ���򵥵ض������б��������á����磬�ո��ַ����� "%20" ȡ�������������á�UTF-8 ���� US-ASCII����˶��� US-ASCII �ַ�����ת�����е�Ч���� RFC 2396 ��Ҫ����ͬ��
    *      ��ת���λ�����н��н��� �ķ����ǣ������������ UTF-8 �ַ����е��ַ������н���ȡ����UTF-8 ���� US-ASCII����˽�����ж����õ��κ� US-ASCII �ַ�ȡ�����õ�Ч�����Լ����κα���ķ� US-ASCII �ַ����н����Ч��������ڶ�ת���λ����н���ʱ���ֽ�����������İ�λ���� Unicode �滻�ַ� '\uFFFD' ȡ����

��Щ�����ڴ���Ĺ��췽���ͷ����й�����������ʾ��

    *      ���������췽��Ҫ��Բ����е��κηǷ��ַ����������ã����������ֵ��κ�ת���λ��� other �ַ���
    *      ��������췽���������г��ֵ���ɲ��ֵ���Ҫ�ԷǷ��ַ��������á��ٷֺ��ַ� ('%') ʼ��ͨ����Щ���췽�����á��κ� other �ַ�������������
    *      getRawUserInfo��getRawPath��getRawQuery��getRawFragment��getRawAuthority �� getRawSchemeSpecificPart ������ԭʼ��ʽ�������ǵ���Ӧ��ɲ��ֵ�ֵ���������κ�ת���λ�顣����Щ�������ص��ַ����п��ܰ���ת���λ��� other �ַ������������κηǷ��ַ���
    *      getUserInfo��getPath��getQuery��getFragment��getAuthority �� getSchemeSpecificPart ����������Ӧ����ɲ����е��κ�ת���λ�顣����Щ�������ص��ַ����п��ܰ��� other �ַ��ͷǷ��ַ������������κ�ת���λ�顣
    *      toString ���ش����б�Ҫ���õ� URI �ַ������������ܰ��� other �ַ���
    *      toASCIIString �������ز������κ� other �ַ��ġ���ȫ���õĺ;�������� URI �ַ�����

��ʶ
�����κ� URI u������ı�ʶ��Ч

    new URI(u.toString()).equals(u) . 

���ڲ����������﷨���κ� URI u��������һ������Ȩǰ��������б�ߣ��� file:///tmp/���������������һ��ð�ŵ�û�ж˿ڣ��� http://java.sun.com:�����Լ����������õ��ַ�֮�ⲻ���ַ���������������ı�ʶҲ��Ч��

    new URI(u.getScheme()��
            u.getSchemeSpecificPart()��
            u.getFragment())
    .equals(u) 

����������£����±�ʶ��Ч

    new URI(u.getScheme()��
            u.getUserInfo()�� u.getAuthority()��
            u.getPath()�� u.getQuery()��
            u.getFragment())
    .equals(u) 

��� u Ϊ�ֲ�ģ������±�ʶ��Ч

    new URI(u.getScheme()��
            u.getUserInfo()�� u.getHost()�� u.getPort()��
            u.getPath()�� u.getQuery()��
            u.getFragment())
    .equals(u) 

��� u Ϊ�ֲ�Ĳ���û����Ȩ��û�л��ڷ���������Ȩ��
URI��URL �� URN
URI ��ͳһ��Դ��ʶ������ URL ��ͳһ��Դ��λ������ˣ���ͳ��˵��ÿ�� URL ���� URI������һ��ÿ�� URI ���� URL��������Ϊ URI ������һ�����࣬��ͳһ��Դ���� (URN)����������Դ����ָ����ζ�λ��Դ������� mailto��news �� isbn URI ���� URN ��ʾ����

URI �� URL �����ϵĲ�ͬ��ӳ�ڴ���� URL ��Ĳ�ͬ�С�

�����ʵ�������� RFC 2396 ������﷨�����ϵ�һ�� URI ���á�URI �����Ǿ��Եģ�Ҳ��������Եġ��� URI �ַ�������һ���﷨���н���������������ָ���ķ���������У���������������У�ִ�в��ң�Ҳ�����������ڷ������������������ԡ���ϣ�����Լ��Ƚ϶��ϸ�ظ���ʵ�����ַ����ݽ��ж��塣���仰˵��һ�� URI ʵ����һ��֧���﷨�����ϵġ������ڷ����ıȽϡ��淶������������Ի�����Ľṹ���ַ�����ࡣ

��Ϊ���գ�URL ���ʵ�������� URL ���﷨��ɲ����Լ���������������Դ�������Ϣ��URL �����Ǿ��Եģ���������ʼ��ָ��һ��������URL �ַ��������䷽�����н�����ͨ����Ϊ URL ����һ�����������ʵ�����޷�Ϊδ�ṩ�������ķ�������һ�� URL ʵ��������Ժ͹�ϣ���������ڷ����������� Internet ��ַ������У���û�ж���Ƚϡ����仰˵��URL ��һ���ṹ���ַ�������֧�ֽ������﷨�����Լ����������ʹ򿪵�ָ����Դ������֮������� I/O ������
}

unit uMeURI;

interface

{$I MeSetting.inc}

uses
  SysUtils
  , uMeObject
  , uMeException
  ;

type
  TMeURIOptionalFields = (ofAuthInfo, ofBookmark);
  TMeURIOptionalFieldsSet = set of TMeURIOptionalFields;
  TMeIpVersion = (ivIPv4, ivIPv6);

  PMeURI = ^ TMeURI;
  TMeURI = object(TMeDynamicObject)
  protected
    FDocument: string;
    FProtocol: string;
    FURI: String;
    FPort: string;
    Fpath: string;
    FHost: string;
    FBookmark: string;
    FUserName: string;
    FPassword: string;
    FParams: string;
    FIPVersion: TMeIpVersion;

    procedure SetURI(const Value: String);
    function GetURI: String;
  public
    destructor Destroy; virtual; { override }
    function GetFullURI(const AOptionalFields: TMeURIOptionalFieldsSet = [ofAuthInfo, ofBookmark]): String;
    function GetPathAndParams: String;
    function Empty: Boolean;
    { Summary: Normalize the directory delimiters to follow the UNIX syntax }
    class procedure NormalizePath(var APath: string);
    class function URLDecode(ASrc: string): string;
    class function URLEncode(const ASrc: string): string;
    class function ParamsEncode(const ASrc: string): string;
    class function PathEncode(const ASrc: string): string;
    { Summary: the Fragment part. }
    property Bookmark : string read FBookmark write FBookmark;
    property Document: string read FDocument write FDocument;
    property Host: string read FHost write FHost;
    property Password: string read FPassword write FPassword;
    property Path: string read FPath write FPath;
    { Sumary: the Query part. }
    property Params: string read FParams write FParams;
    property Port: string read FPort write FPort;
    { Summary: the Scheme part}
    { 
    Components of all URIs: [<scheme>:]<scheme-specific-part>[#<fragment>]
    null ==> relative URI
    }
    property Protocol: string read FProtocol write FProtocol;
    property URI: string read GetURI write SetURI;
    property Username: string read FUserName write FUserName;
    property IPVersion : TMeIpVersion read FIPVersion write FIPVersion;
  end;

resourcestring
  RSURINoProto                 = 'Protocol field is empty';
  RSURINoHost                  = 'Host field is empty';

implementation

uses
  uMeSystem, uMeStrUtils;

{ TMeURI }
destructor TMeURI.Destroy;
begin
  FURI := '';
  FProtocol := '';
  FParams := '';
  FHost := '';
  FPort := '';
  FPassword := '';
  FBookmark := '';
  FPath := '';
  FUserName := '';
  FDocument := '';
  inherited;
end;

class procedure TMeURI.NormalizePath(var APath: string);
var
  i: Integer;
begin
  i := 1;
  while i <= Length(APath) do begin
    if IsLeadChar(APath[i]) then begin
      inc(i, 2)
    end else if APath[i] = '\' then begin    {Do not Localize}
      APath[i] := '/';    {Do not Localize}
      inc(i, 1);
    end else begin
      inc(i, 1);
    end;
  end;
end;
function TMeURI.Empty: Boolean;
begin
  Result := FURI = '';
end;

procedure TMeURI.SetURI(const Value: String);
var
  LBuffer: string;
  LTokenPos: Integer;
  LURI: string;
begin
  FURI := Value;
  NormalizePath(FURI);
  LURI := FURI;
  FHost := '';    {Do not Localize}
  FProtocol := '';    {Do not Localize}
  FPath := '';    {Do not Localize}
  FDocument := '';    {Do not Localize}
  FPort := '';    {Do not Localize}
  FBookmark := '';    {Do not Localize}
  FUsername := '';    {Do not Localize}
  FPassword := '';    {Do not Localize}
  FParams := '';  {Do not localise}  //Peter Mee
  FIPVersion := ivIPv4;

  // Parse the # bookmark from the document
  LTokenPos := RPos('#', LURI);    {Do not Localize}
  FBookmark := LURI;
  LURI := StrFetch(FBookmark, '#');    {Do not Localize}

  LTokenPos := AnsiPos(':', LURI);    {Do not Localize}
  if LTokenPos > 0 then begin
    // absolute URI
    // What to do when data don't match configuration ??    {Do not Localize}
    // Get the protocol
    FProtocol := Copy(LURI, 1, LTokenPos  - 1);
    Delete(LURI, 1, LTokenPos);
    {if (Length(LURI) >=2) and (LURI[1] = '/') and (LURI[2] = '/') then
    begin
      //it's a URL
      Delete(LURI, 1, 2);
    end;
    //else //it is a URN}

    // separate the path from the parameters
    LTokenPos := AnsiPos('?', LURI);    {Do not Localize}
    if LTokenPos = 0 then begin
      LTokenPos := AnsiPos('=', LURI);    {Do not Localize}
    end;
    if LTokenPos > 0 then begin
      FParams := Copy(LURI, LTokenPos + 1, MaxInt);
      LURI := Copy(LURI, 1, LTokenPos - 1);
    end;
    // Get the user name, password, host and the port number
    LBuffer := LURI;
    while (Length(LBuffer) > 0) and (LBuffer[1] = '/') do  //Get rid of the '//', the result is 'user:pwd@host:port/xxx/xx'
      Delete(LBuffer, 1, 1);
    LTokenPos := RPos('/', LBuffer);
    if LTokenPos > 0 then
    begin
      FPath := Copy(LBuffer, 1, LTokenPos-1);
      LTokenPos := RPos('/', LURI);
      FDocument := Copy(LURI, LTokenPos+1, MaxInt);
      //remove the path part, the result is 'user:pwd@host:port'
      LBuffer := StrFetch(FPath, '/', True);    {Do not Localize}
      if (FPath <> '') and (FPath[Length(FPath)] <> '/') then
        FPath := '/' + FPath + '/';
    end
    else
    begin
      FDocument := '';
      FPath := '';
      LURI := ''; //no path
    end;
    // Get username and password
    LTokenPos := AnsiPos('@', LBuffer);    {Do not Localize}
    if LTokenPos > 0 then begin
      FUsername := Copy(LBuffer, 1, LTokenPos  - 1);
      Delete(LBuffer, 1, LTokenPos);
      LTokenPos := AnsiPos(':', FUsername);    {Do not Localize}
      if LTokenPos > 0 then begin
        FPassword := Copy(FUsername, LTokenPos+1, MaxInt);
        FUsername := Copy(FUsername, 1, LTokenPos-1);
      end;
      // Ignore cases where there is only password (http://:password@host/pat/doc)
      if Length(FUserName) = 0 then begin
        FPassword := '';    {Do not Localize}
      end;
    end;
    // Get the host and the port number
    if (AnsiPos('[', LBuffer) > 0) and (AnsiPos(']', LBuffer) > AnsiPos('[', LBuffer)) then begin {Do not Localize}
      //This is for IPv6 Hosts
      FHost := StrFetch(LBuffer, ']'); {Do not Localize}
      StrFetch(FHost, '['); {Do not Localize}
      StrFetch(LBuffer, ':'); {Do not Localize}
      FIPVersion := ivIPv6;
    end else begin
      FHost := StrFetch(LBuffer, ':', True);    {Do not Localize}
    end;
    FPort := LBuffer;
    
    (*
    // Get the path
    LTokenPos := RPos('/', LURI);
    if LTokenPos > 0 then begin
      FPath := '/' + Copy(LURI, 1, LTokenPos);    {Do not Localize}
      Delete(LURI, 1, LTokenPos);
    end else begin
      FPath := '';    {Do not Localize}
    end;
    *)
  end else begin
    // received an absolute path, not an URI
    LTokenPos := AnsiPos('?', LURI);    {Do not Localize}
    if LTokenPos = 0 then begin
      LTokenPos := AnsiPos('=', LURI);    {Do not Localize}
    end;
    if LTokenPos > 0 then begin // The case when there is parameters after the document name
      FParams := Copy(LURI, LTokenPos + 1, MaxInt);
      LURI := Copy(LURI, 1, LTokenPos - 1);
    end;
    // Get the path
    LTokenPos := RPos('/', LURI);    {Do not Localize}
    if LTokenPos > 0 then begin
      FPath := Copy(LURI, 1, LTokenPos);
      Delete(LURI, 1, LTokenPos);
    end;
    // Get the document
    FDocument := LURI;
  end;
end;

function TMeURI.GetURI: String;
begin
  FURI := GetFullURI;
  // Result must contain only the proto://host/path/document
  // If you need the full URI then you have to call GetFullURI
  Result := GetFullURI([]);
end;

class function TMeURI.URLDecode(ASrc: string): string;
var
  i: Integer;
  ESC: string[4];
  CharCode: Integer;
begin
  Result := '';    {Do not Localize}
  // S.G. 27/11/2002: Spaces is NOT to be encoded as "+".
  // S.G. 27/11/2002: "+" is a field separator in query parameter, space is...
  // S.G. 27/11/2002: well, a space
  // ASrc := StringReplace(ASrc, '+', ' ', [rfReplaceAll]);  {do not localize}
  i := 1;
  while i <= Length(ASrc) do begin
    if ASrc[i] <> '%' then begin  {do not localize}
      Result := Result + ASrc[i]; // Copy the char
      Inc(i); // Then skip it
    end else begin
      Inc(i); // skip the % char
      if not CharIsInSet(ASrc, i, 'uU') then begin  {do not localize}
        // simple ESC char
        ESC := Copy(ASrc, i, 2); // Copy the escape code
        Inc(i, 2); // Then skip it.
        try
          CharCode := StrToInt('$' + ESC);  {do not localize}
          Result := Result + Char(CharCode);
        except end;
      end else
      begin
        // unicode ESC code

        // RLebeau 5/10/2006: under Win32, the character will end
        // up as '?' in the Result when converted from Unicode to Ansi,
        // but at least the URL will be parsed properly
        
        ESC := Copy(ASrc, i+1, 4); // Copy the escape code
        Inc(i, 5); // Then skip it.
        try
          CharCode := StrToInt('$' + ESC);  {do not localize}
          Result := Result + WideChar(CharCode);
        except end;
      end;
    end;
  end;
end;

class function TMeURI.ParamsEncode(const ASrc: string): string;
var
  i: Integer;
const
  UnsafeChars = '*#%<> []';  {do not localize}
begin
  Result := '';    {Do not Localize}
  for i := 1 to Length(ASrc) do
  begin
    // S.G. 27/11/2002: Changed the parameter encoding: Even in parameters, a space
    // S.G. 27/11/2002: is much more likely to be meaning "space" than "this is
    // S.G. 27/11/2002: a new parameter"
    // S.G. 27/11/2002: ref: Message-ID: <3de30169@newsgroups.borland.com> borland.public.delphi.internet.winsock
    // S.G. 27/11/2002: Most low-ascii is actually Ok in parameters encoding.
    if CharIsInSet(ASrc, i, UnsafeChars) or (not CharIsInSet(ASrc, i, CharRange(#33,#128))) then begin {do not localize}
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2);  {do not localize}
    end else begin
      Result := Result + ASrc[i];
    end;
  end;
end;

class function TMeURI.PathEncode(const ASrc: string): string;
const
  UnsafeChars = '*#%<>+ []';  {do not localize}
var
  i: Integer;
begin
  Result := '';    {Do not Localize}
  for i := 1 to Length(ASrc) do begin
    if CharIsInSet(ASrc, i, UnsafeChars) or (not CharIsInSet(ASrc, i, CharRange(#32, #127))) then begin
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2);  {do not localize}
    end else begin
      Result := Result + ASrc[i];
    end;
  end;
end;

class function TMeURI.URLEncode(const ASrc: string): string;
begin
  with New(PMeURI, Create)^ do 
  try
    URI := aSrc;
    Path := PathEncode(Path);
    Document := PathEncode(Document);
    Params := ParamsEncode(Params);
    Result := URI;
  finally 
    Free; 
  end;
end;

function TMeURI.GetFullURI(const AOptionalFields: TMeURIOptionalFieldsSet): String;
var
  LURI: String;
begin
  if FProtocol = '' then begin
    raise EMeError.Create(RSURINoProto);
  end;

  if FHost = '' then begin
    raise EMeError.Create(RSURINoHost);
  end;

  LURI := FProtocol + '://';    {Do not Localize}

  if (FUserName <> '') and (ofAuthInfo in AOptionalFields) then begin
    LURI := LURI + FUserName;
    if FPassword <> '' then begin
      LURI := LURI + ':' + FPassword;    {Do not Localize}
    end;
    LURI := LURI + '@';    {Do not Localize}
  end;

  LURI := LURI + FHost;
  if FPort <> '' then begin
    case PosInStrArray(FProtocol, ['HTTP', 'HTTPS', 'FTP'], False) of {Do not Localize}
      0:
        begin
          if FPort <> '80' then begin
            LURI := LURI + ':' + FPort;    {Do not Localize}
          end;
        end;
      1:
        begin
          if FPort <> '443' then begin
            LURI := LURI + ':' + FPort;    {Do not Localize}
          end;
        end;
      2:
        begin
          if FPort <> '21' then begin
            LURI := LURI + ':' + FPort;    {Do not Localize}
          end;
        end;
      else
        begin
          LURI := LURI + ':' + FPort;    {Do not Localize}
        end;
    end;
  end;

  LURI := LURI + GetPathAndParams;

  if (FBookmark <> '') and (ofBookmark in AOptionalFields) then begin
    LURI := LURI + '#' + FBookmark;    {Do not Localize}
  end;

  Result := LURI;
end;

function TMeURI.GetPathAndParams: String;
begin
  Result := FPath + FDocument;
  if FParams <> '' then begin
    Result := Result + '?' + FParams; {Do not Localize}
  end;
end;

end.
