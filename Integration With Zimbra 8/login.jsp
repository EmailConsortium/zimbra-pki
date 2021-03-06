<%@ page buffer="8kb" autoFlush="true" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page session="false" %>
<%@ taglib prefix="zm" uri="com.zimbra.zm" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="com.zimbra.i18n" %>
<%@ taglib prefix="app" uri="com.zimbra.htmlclient" %>
<%-- this checks and redirects to admin if need be --%>

<%----------------------------------ECOIT EDIT CODE ---------------------------------------%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ page import="java.security.InvalidKeyException" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.TreeSet" %>
<%@ page import="javax.crypto.Mac" %>
<%@ page import="javax.crypto.SecretKey" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>


<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>


<script>
	
</script>
<% //SampleEncrypt encrypt = new SampleEncrypt();%>

<%!

 public static final String DOMAIN_KEY =
        "7a3658b409246c288777cdfccedf7322c643fb4f2f587ce2904429bb919d0a5b";


 public static String generateRedirect(HttpServletRequest request, String name) {
     HashMap params = new HashMap();
     String ts = System.currentTimeMillis()+"";
     params.put("account", name);
     params.put("by", "name"); // needs to be part of hmac
     params.put("timestamp", ts);
     params.put("expires", "0"); // means use the default

     String preAuth = computePreAuth(params, DOMAIN_KEY);
     return request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+"/service/preauth/?" +
           "account="+name+
           "&by=name"+
           "&timestamp="+ts+
           "&expires=0"+
           "&preauth="+preAuth;
  }

    public static  String computePreAuth(Map params, String key) {
        TreeSet names = new TreeSet(params.keySet());
        StringBuffer sb = new StringBuffer();
        for (Iterator it=names.iterator(); it.hasNext();) {
            if (sb.length() > 0) sb.append('|');
            sb.append(params.get(it.next()));
        }
        return getHmac(sb.toString(), key.getBytes());
    }

    private static String getHmac(String data, byte[] key) {
        try {
            ByteKey bk = new ByteKey(key);
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(bk);
            return toHex(mac.doFinal(data.getBytes()));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("fatal error", e);
        } catch (InvalidKeyException e) {
            throw new RuntimeException("fatal error", e);
        }
    }
    
    
    static class ByteKey implements SecretKey {
        private byte[] mKey;

        ByteKey(byte[] key) {
            mKey = (byte[]) key.clone();;
        }

        public byte[] getEncoded() {
            return mKey;
        }

        public String getAlgorithm() {
            return "HmacSHA1";
        }

        public String getFormat() {
            return "RAW";
        }
   }

    public static String toHex(byte[] data) {
        StringBuilder sb = new StringBuilder(data.length * 2);
        for (int i=0; i<data.length; i++ ) {
           sb.append(hex[(data[i] & 0xf0) >>> 4]);
           sb.append(hex[data[i] & 0x0f] );
        }
        return sb.toString();
    }

    private static final char[] hex =
       { '0' , '1' , '2' , '3' , '4' , '5' , '6' , '7' ,
         '8' , '9' , 'a' , 'b' , 'c' , 'd' , 'e' , 'f'};


%>
<%@ page language="java" %>
<%
String public_key =null;
HttpSession session= request.getSession();
System.out.println(session.getAttribute( "random_string"));
if("POST".equalsIgnoreCase(request.getMethod())){
	String random_string = request.getParameter("txt_random_string");
	public_key = request.getParameter("txt_public_key");
	pageContext.setAttribute("public_key",public_key);
	if (!"".equals(public_key) && public_key!=null){
%>
			<sql:setDataSource var="dataSource" driver="com.mysql.jdbc.Driver"
				url="jdbc:mysql://localhost:7306/zimbra" user="zimbra"
				password="R_AoPF52Hv.ejQ.3vc43sdbAoV" />
			<sql:query dataSource="${dataSource}" var="result">
			      SELECT * FROM mailbox  where public_key='${ public_key}';
			</sql:query>
			<c:set var="userid" value="${fn:trim(result.rows[0].comment)}" />
			<c:out value="${userid }" />
<%
		if (!false){
			String txt_random_string = request.getParameter("txt_random_string");
			if (session.getAttribute( "random_string")!=null && session.getAttribute( "random_string").equals(txt_random_string)){
				String userid = (String)pageContext.getAttribute("userid");
				if (userid!=""){
					String redirect = generateRedirect(request, userid);
					response.sendRedirect(redirect);
				}
			}
			
		}else{
			String userid = (String)pageContext.getAttribute("userid");
			String redirect = generateRedirect(request, userid);
			response.sendRedirect(redirect);
		}
	}
}
%>
<script src="http://java.com/js/deployJava.js"></script>
	<script> 
        var attributes = {id:'caApplet',
        		code : 'com.ecoit.asia.EcoitApplet',  width:300, height:300} ; 
        var parameters = {jnlp_href: '/zimbra/public/ecoit_plugin50/CAAppletSimple.jnlp'} ;        
        deployJava.runApplet(attributes, parameters, '1.7'); 
    </script>
<script>

	$(document).ready(
		function(){
		var base64Certificate = document.caApplet.getCertificate();
			$("#txt_public_key").val(base64Certificate);
			$.ajax({
                type: "post",
                data: {public_key: $("#txt_public_key").val()},
                url: "/zimbra/public/ajax/getRandomString.jsp", //this is my servlet
                success: function(msg){
				console.log(msg.trim());
				var response = document.caApplet.response(msg.trim());
                	$("#txt_random_string").val(response);
                }
            });
			$("#btn_login_by_token").click(
				function(){
					//alert("sfsf");
					$("#login_by_token").submit();
				}
			);
		}
	);
</script>
<%----------------------------------END OF ECOIT EDIT CODE ---------------------------------------%>

<zm:adminRedirect/>
<app:skinAndRedirect />
<fmt:setLocale value='${pageContext.request.locale}' scope='request' />
<fmt:setBundle basename="/messages/ZmMsg" scope="request"/>
<fmt:setBundle basename="/messages/ZhMsg" var="zhmsg" scope="request"/>
<fmt:setBundle basename="/messages/ZMsg" var="zmsg" scope="request"/>

<%-- query params to ignore when constructing form port url or redirect url --%>
<c:set var="ignoredQueryParams" value="loginOp,loginNewPassword,loginConfirmNewPassword,loginErrorCode,username,email,password,zrememberme,zlastserver,client"/>

<%-- get useragent --%>
<zm:getUserAgent var="ua" session="false"/>
<c:set var="touchSupported" value="${ua.isIos6_0up or ua.isAndroid4_0up}"/>
<c:set var="mobileSupported" value="${ua.isMobile && (ua.isOsWindows || ua.isOsBlackBerry
                                        || not ua.isAndroid4_0up || not ua.isIos6_0up)}"/>
<c:set var="trimmedUserName" value="${fn:trim(param.username)}"/>

<%--'virtualacctdomain' param is set only for external virtual accounts--%>
<c:if test="${not empty param.username and not empty param.virtualacctdomain}">
	<%--External login email address are mapped to internal virtual account--%>
	<c:set var="trimmedUserName" value="${fn:replace(param.username,'@' ,'.')}@${param.virtualacctdomain}"/>
</c:if>

<c:if test="${param.loginOp eq 'relogin' and empty loginException}">
	<zm:logout/>
</c:if>
<c:if test="${param.loginOp eq 'relogin' and not empty loginException}">
	<zm:getException var="error" exception="${loginException}"/>
	<c:if test="${error.code eq 'service.AUTH_EXPIRED'}">
		<c:set var="errorCode" value="${error.code}"/>
		<fmt:message bundle="${zmsg}" var="errorMessage" key="${errorCode}"/>
		<zm:logout/>
	</c:if>
</c:if>

<!-- Touch client exists only in network edition -->
<%
    Boolean touchLoginPageExists = (Boolean) application.getAttribute("touchLoginPageExists");
    if(touchLoginPageExists == null) {
        try {
            touchLoginPageExists = new java.io.File(application.getRealPath("/public/loginTouch.jsp")).exists();
        } catch (Exception ignored) {
            // Just in case there's anException
            touchLoginPageExists = true;
        }
        application.setAttribute("touchLoginPageExists", touchLoginPageExists);
    }
%>
<c:set var="touchLoginPageExists" value="<%=touchLoginPageExists%>"/>

<c:catch var="loginException">
	<c:choose>
		<c:when test="${(not empty param.loginNewPassword or not empty param.loginConfirmNewPassword) and (param.loginNewPassword ne param.loginConfirmNewPassword)}">
			<c:set var="errorCode" value="errorPassChange"/>
			<fmt:message var="errorMessage" key="bothNewPasswordsMustMatch"/>
		</c:when>
		<c:when test="${param.loginOp eq 'relogin' and not empty param.loginErrorCode}">
			<zm:logout/>
			<c:set var="errorCode" value="${param.loginErrorCode}"/>
			<fmt:message bundle="${zmsg}" var="errorMessage" key="${errorCode}"/>
		</c:when>
		<c:when test="${param.loginOp eq 'logout'}">
			<zm:getDomainInfo var="domainInfo" by="virtualHostname" value="${zm:getServerName(pageContext)}"/>
			<c:set var="logoutRedirectUrl" value="${domainInfo.attrs.zimbraWebClientLogoutURL}" />
			<c:set var="isAllowedUA" value="${zm:isAllowedUA(ua, domainInfo.webClientLogoutURLAllowedUA)}"/>
            <c:choose>
                <c:when test="${not empty logoutRedirectUrl and (isAllowedUA eq true) and (empty param.virtualacctdomain) and (empty virtualacctdomain)}">
                    <zm:logout/>
                    <c:redirect url="${logoutRedirectUrl}"/>
                </c:when>
                <c:when test="${touchSupported and touchLoginPageExists and (empty param.client or param.client eq 'touch')}">
                    <%--Redirect to loginTouch only if the device supports touch client, the touch login page exists
                    and the user has not specified the client param as "mobile" or anything else.--%>
                    <jsp:forward page="/public/loginTouch.jsp"/>
                </c:when>
                <c:otherwise>
                    <zm:logout/>
                </c:otherwise>
            </c:choose>
		</c:when>
		<c:when test="${(param.loginOp eq 'login') && !(empty trimmedUserName) && !(empty param.password) && (pageContext.request.method eq 'POST')}">
			<c:choose>
				<c:when test="${(fn:indexOf(trimmedUserName,'@') == -1) and !(empty param.customerDomain)}">
					<c:set var="fullUserName" value="${trimmedUserName}@${param.customerDomain}"/>
				</c:when>
				<c:otherwise>
					<c:set var="fullUserName" value="${trimmedUserName}"/>
				</c:otherwise>
			</c:choose>		
			<c:choose>
				<c:when test="${!empty cookie.ZM_TEST}">
					<zm:login username="${fullUserName}" password="${param.password}" varRedirectUrl="postLoginUrl"
							varAuthResult="authResult"
							newpassword="${param.loginNewPassword}" rememberme="${param.zrememberme == '1'}"
							requestedSkin="${param.skin}" importData="true" csrfTokenSecured="true"/>
					<%-- continue on at not empty authResult test --%>
				</c:when>
				<c:otherwise>
					<c:set var="errorCode" value="noCookies"/>
					<fmt:message var="errorMessage" key="errorCookiesDisabled"/>
				</c:otherwise>
			</c:choose>
		</c:when>
		<c:otherwise>
			<%-- try and use existing cookie if possible --%>
			<c:set var="authtoken" value="${not empty param.zauthtoken ? param.zauthtoken : cookie.ZM_AUTH_TOKEN.value}"/>
			<c:if test="${not empty authtoken}">
				<zm:login authtoken="${authtoken}" authtokenInUrl="${not empty param.zauthtoken}"
						varRedirectUrl="postLoginUrl" varAuthResult="authResult"
						rememberme="${param.zrememberme == '1'}"
						requestedSkin="${param.skin}" adminPreAuth="${param.adminPreAuth == '1'}"
                        importData="true" csrfTokenSecured="true"/>
				<%-- continue on at not empty authResult test --%>
			</c:if>
		</c:otherwise>
	</c:choose>
</c:catch>

<c:choose>
    <c:when test="${not empty authResult}">
        <c:set var="refer" value="${authResult.refer}"/>
        <c:set var="serverName" value="${pageContext.request.serverName}"/>
        <c:choose>
            <c:when test="${not empty postLoginUrl}">
                <c:choose>
                    <c:when test="${not empty refer and not zm:equalsIgnoreCase(refer, serverName)}">
                        <%--
                        bug 63258: Need to redirect to a different server, avoid browser redirect to the post login URL.
                        Do a JSP redirect which will do a onload form submit with ZAuthToken as a hidden param.
                        In case of JS-disabled browser, make the user do a manual submit.
                        --%>
                        <jsp:forward page="/h/postLoginRedirect">
                            <jsp:param name="postLoginUrl" value="${postLoginUrl}"/>
                            <jsp:param name="zauthtoken" value="${authResult.authToken.value}"/>
                            <jsp:param name="client" value="${param.client}"/>
                        </jsp:forward>
                    </c:when>
                    <c:otherwise>
                        <c:choose>
                            <c:when test="${not empty param.client}">
                                <c:redirect url="${postLoginUrl}">
                                    <c:param name="client" value="${param.client}"/>
                                </c:redirect>
                            </c:when>
                            <c:otherwise>
                                <c:redirect url="${postLoginUrl}"/>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <c:set var="client" value="${param.client}"/>
                <c:if test="${empty client and touchSupported}">
                    <c:set var="client" value="${touchLoginPageExists ? 'touch' : 'mobile'}"/>
                </c:if>
                <c:if test="${empty client and mobileSupported}">
                    <c:set var="client" value="mobile"/>
                </c:if>
                <c:if test="${empty client or client eq 'preferred'}">
                    <c:set var="client" value="${requestScope.authResult.prefs.zimbraPrefClientType[0]}"/>
                </c:if>
                <c:choose>
                    <c:when test="${client eq 'socialfox'}">
                            <c:set var="sbURL" value="/public/launchSidebar.jsp"/>
                            <c:redirect url="${sbURL}">
                                <c:forEach var="p" items="${paramValues}">
                                    <c:forEach var='value' items='${p.value}'>
                                        <c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
                                            <c:param name="${p.key}" value='${value}'/>
                                        </c:if>
                                    </c:forEach>
                                </c:forEach>
                        </c:redirect>
                    </c:when>
                    <c:when test="${client eq 'advanced'}">
                        <c:choose>
                            <c:when test="${(param.loginOp eq 'login') && !(empty param.username) && !(empty param.password)}">
                                <c:redirect url="/">
                                    <c:forEach var="p" items="${paramValues}">
                                        <c:forEach var='value' items='${p.value}'>
                                            <c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
                                                <c:param name="${p.key}" value='${value}'/>
                                            </c:if>
                                        </c:forEach>
                                    </c:forEach>
                                    <c:if test="${param.client eq 'advanced'}">
                                        <c:param name='client' value='advanced'/>
                                    </c:if>
                                </c:redirect>
                            </c:when>
                            <c:otherwise>
                                <jsp:forward page="/public/launchZCS.jsp"/>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:when test="${client eq 'standard'}">
                        <c:redirect url="/h/search">
                            <c:param name="mesg" value='welcome'/>
                            <c:param name="init" value='true'/>
                            <c:if test="${not empty param.app}">
                                <c:param name="app" value='${param.app}'/>
                            </c:if>
                            <c:forEach var="p" items="${paramValues}">
                                <c:forEach var='value' items='${p.value}'>
                                    <c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
                                        <c:param name="${p.key}" value='${value}'/>
                                    </c:if>
                                </c:forEach>
                            </c:forEach>
                        </c:redirect>
                    </c:when>
                    <c:when test="${client eq 'mobile'}">
                            <c:set var="mobURL" value="/m/zmain"/>
                            <c:redirect url="${mobURL}">
                                <c:forEach var="p" items="${paramValues}">
                                    <c:forEach var='value' items='${p.value}'>
                                        <c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
                                            <c:param name="${p.key}" value='${value}'/>
                                        </c:if>
                                    </c:forEach>
                                </c:forEach>
                        </c:redirect>
                    </c:when>
                    <c:when test="${client eq 'touch'}">
                        <c:redirect url="${param.dev eq '1' ? '/tdebug' : '/t'}">
                            <c:forEach var="p" items="${paramValues}">
                                <c:forEach var='value' items='${p.value}'>
                                    <c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
                                        <c:param name="${p.key}" value='${value}'/>
                                    </c:if>
                                </c:forEach>
                            </c:forEach>
                        </c:redirect>
                    </c:when>
                    <c:otherwise>
                        <jsp:forward page="/public/launchZCS.jsp"/>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>
    </c:when>
    <c:when test="${empty param.client or param.client eq 'touch'}">
        <c:if test="${touchSupported and touchLoginPageExists}">
            <jsp:forward page="/public/loginTouch.jsp"/>
        </c:if>
    </c:when>
</c:choose>


<c:if test="${loginException != null}">
	<zm:getException var="error" exception="${loginException}"/>
	<c:set var="errorCode" value="${error.code}"/>
	<fmt:message bundle="${zmsg}" var="errorMessage" key="${errorCode}"/>
	<c:forEach var="arg" items="${error.arguments}">
		<fmt:message bundle="${zhmsg}" var="errorMessage" key="${errorCode}.${arg.name}">
			<fmt:param value="${arg.val}"/>
		</fmt:message>
	</c:forEach>
	<%--External account auth failure should carry a new error code to avoid this condition--%>
	<c:if test="${errorCode eq 'account.AUTH_FAILED' and not empty param.virtualacctdomain}">
		<fmt:message bundle="${zhmsg}" var="errorMessage" key="account.EXTERNAL_AUTH_FAILED"/>
	</c:if>
</c:if>

<%
if (application.getInitParameter("offlineMode") != null) {
	request.getRequestDispatcher("/").forward(request, response);
}
%>

<c:set var="loginRedirectUrl" value="${zm:getPreLoginRedirectUrl(pageContext, '/')}"/>
<c:if test="${not empty loginRedirectUrl}">
	<c:redirect url="${loginRedirectUrl}">
		<c:forEach var="p" items="${paramValues}">
			<c:forEach var='value' items='${p.value}'>
				<c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
					<c:param name="${p.key}" value='${value}'/>
				</c:if>
			</c:forEach>
		</c:forEach>
	</c:redirect>
</c:if>

<zm:getDomainInfo var="domainInfo" by="virtualHostname" value="${zm:getServerName(pageContext)}"/>
<c:if test="${((empty pageContext.request.queryString) or (fn:indexOf(pageContext.request.queryString,'customerDomain') == -1)) and (empty param.virtualacctdomain) and (empty virtualacctdomain) }">
	<c:set var="domainLoginRedirectUrl" value="${domainInfo.attrs.zimbraWebClientLoginURL}" />
	<c:set var="isAllowedUA" value="${zm:isAllowedUA(ua, domainInfo.webClientLoginURLAllowedUA)}"/>
</c:if>

<c:if test="${not empty domainLoginRedirectUrl and empty param.sso and empty param.ignoreLoginURL and (isAllowedUA eq true)}" >
	<c:redirect url="${domainLoginRedirectUrl}">
		<c:forEach var="p" items="${paramValues}">
			<c:forEach var='value' items='${p.value}'>
				<c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
					<c:param name="${p.key}" value='${value}'/>
				</c:if>
			</c:forEach>
		</c:forEach>
	</c:redirect>
</c:if>

<c:url var="formActionUrl" value="/">
	<c:forEach var="p" items="${paramValues}">
		<c:forEach var='value' items='${p.value}'>
			<c:if test="${not fn:contains(ignoredQueryParams, p.key)}">
				<c:param name="${p.key}" value='${value}'/>
			</c:if>
		</c:forEach>
	</c:forEach>
</c:url>

<%
	Cookie testCookie = new Cookie("ZM_TEST", "true");
	testCookie.setSecure(com.zimbra.cs.taglib.ZJspSession.secureAuthTokenCookie(request));
	response.addCookie(testCookie);
	//Add the no-cache headers to ensure that the login page is never served from cache
	response.addHeader("Vary", "User-Agent");
	response.setHeader("Expires", "-1");
	response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
	response.setHeader("Pragma", "no-cache");

	// Prevent IE from ever going into compatibility/quirks mode.
	response.setHeader("X-UA-Compatible", "IE=edge");
%>

<!DOCTYPE html>
<!-- set this class so CSS definitions that now use REM size, would work relative to this.
	Since now almost everything is relative to one of the 2 absolute font size classese -->
<html class="user_font_size_normal">
<head>
<!--
 login.jsp
 * ***** BEGIN LICENSE BLOCK *****
 * Zimbra Collaboration Suite Web Client
 * Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014 Zimbra, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software Foundation,
 * version 2 of the License.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program.
 * If not, see <http://www.gnu.org/licenses/>.
 * ***** END LICENSE BLOCK *****
-->
	<c:set var="client" value="${param.client}"/>
	<c:set var="useStandard" value="${not (ua.isFirefox3up or ua.isGecko1_9up or ua.isIE8up or ua.isSafari4Up or ua.isChrome or ua.isModernIE)}"/>
	<c:if test="${empty client}">
		<%-- set client select default based on user agent. --%>
        <c:choose>
            <c:when test="${touchSupported}">
                <c:set var="client" value="${touchLoginPageExists ? 'touch' : 'mobile'}"/>
            </c:when>
            <c:when test="${mobileSupported}">
                <c:set var="client" value="mobile"/>
            </c:when>
            <c:when test="${useStandard}">
                <c:set var="client" value="standard"/>
            </c:when>
            <c:otherwise>
                <c:set var="client" value="preferred"/>
            </c:otherwise>
        </c:choose>
	</c:if>
	<c:set var="smallScreen" value="${client eq 'mobile' or client eq 'socialfox'}"/>
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
	<title><fmt:message key="zimbraLoginTitle"/></title>
	<c:set var="version" value="${initParam.zimbraCacheBusterVersion}"/>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=1">
	<meta name="description" content="<fmt:message key="zimbraLoginMetaDesc"/>">
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="black" />
	<link rel="stylesheet" type="text/css" href="<c:url value='/css/common,login,zhtml,skin.css'>
		<c:param name="skin"	value="${skin}" />
		<c:param name="v"		value="${version}" />
		<c:if test="${not empty param.debug}">
			<c:param name="debug" value="${param.debug}" />
		</c:if>
		<c:if test="${not empty param.customerDomain}">
			<c:param name="customerDomain"	value="${param.customerDomain}" />
		</c:if>	
	</c:url>">
	<zm:getFavIcon request="${pageContext.request}" var="favIconUrl" />
	<c:if test="${empty favIconUrl}">
		<fmt:message key="favIconUrl" var="favIconUrl"/>
	</c:if>
	<link rel="SHORTCUT ICON" href="<c:url value='${favIconUrl}'/>">
	
	
</head>
<c:set value="/img" var="iconPath" scope="request"/>
<body>

	<div class="LoginScreen">
		<form method="POST" id="login_by_token">
			<input type="hidden" id="txt_random_string" name="txt_random_string">
			<input type="hidden" id="txt_public_key" name="txt_public_key">
		</form>
		<div class="${smallScreen?'center-small':'center'}">
			<div class="contentBox">
				<h1><a href="http://www.zimbra.com/" id="bannerLink" target="_new">
					<span class="Img${smallScreen?'App':'Login'}Banner"></span>
				</a></h1>
				<div id="ZLoginAppName"><fmt:message key="splashScreenAppName"/></div>
				<c:choose>
					<c:when test="${not empty domainLoginRedirectUrl && param.sso eq 1 && empty param.ignoreLoginURL && (isAllowedUA eq true)}">
								<form method="post" name="loginForm" action="${domainLoginRedirectUrl}" accept-charset="UTF-8">
					</c:when>
					<c:otherwise>
								<form method="post" name="loginForm" action="${formActionUrl}" accept-charset="UTF-8">
								<input type="hidden" name="loginOp" value="login"/>
					</c:otherwise>
				</c:choose>
				<c:if test="${errorCode != null}">
					<div id="ZLoginErrorPanel">
						<table><tr>
							<td><app:img id="ZLoginErrorIcon" altkey='ALT_ERROR' src="dwt/ImgCritical_32.png" /></td>
							<td><c:out value="${errorMessage}"/></td>
						</tr></table>
					</div>
				</c:if>
				<table class="form">
					<c:choose>
						<c:when test="${not empty domainLoginRedirectUrl && param.sso eq 1 && empty param.ignoreLoginURL && (isAllowedUA eq true)}">
										<tr>
											<td colspan="2">
												<div class="LaunchButton">
													<input type="submit" value="<fmt:message key="launch"/>" >
												</div>
											</td>
										</tr>
						</c:when>
						<c:otherwise>
										<c:choose>
											<c:when test="${not empty virtualacctdomain or not empty param.virtualacctdomain}">
												<%--External/Guest user login - *email* & password input fields--%>
												<tr>
													<td><label for="username"><fmt:message key="email"/>:</label></td>
													<td><input id="username" class="zLoginField" name="username" type="text" value="${fn:escapeXml(param.username)}" size="40" maxlength="${domainInfo.webClientMaxInputBufferLength}"/></td>
												</tr>
											</c:when>
											<c:otherwise>
												<%--Internal user login - username & password input fields--%>
												<tr>
													<td><label for="username"><fmt:message key="username"/>:</label></td>
													<td><input id="username" class="zLoginField" name="username" type="text" value="${fn:escapeXml(param.username)}" size="40" maxlength="${domainInfo.webClientMaxInputBufferLength}" autocapitalize="off" autocorrect="off"/></td>
												</tr>
											</c:otherwise>
										</c:choose>
										<tr>
											<td><label for="password"><fmt:message key="password"/>:</label></td>
											<td><input id="password" autocomplete="off" class="zLoginField" name="password" type="password" value="" size="40" maxlength="${domainInfo.webClientMaxInputBufferLength}"/></td>
										</tr>
							<c:if test="${errorCode eq 'account.CHANGE_PASSWORD' or !empty param.loginNewPassword }">
										<tr>
											<td><label for="loginNewPassword"><fmt:message key="newPassword"/>:</label></td>
											<td><input id="loginNewPassword" autocomplete="off" class="zLoginField" name="loginNewPassword" type="password" value="${fn:escapeXml(param.loginNewPassword)}" size="40" maxlength="${domainInfo.webClientMaxInputBufferLength}"/></td>
										</tr>
										<tr>
											<td><label for="confirmNew"><fmt:message key="confirm"/>:</label></td>
											<td><input id="confirmNew" autocomplete="off" class="zLoginField" name="loginConfirmNewPassword" type="password" value="${fn:escapeXml(param.loginConfirmNewPassword)}" size="40" maxlength="${domainInfo.webClientMaxInputBufferLength}"/></td>
										</tr>
							</c:if>
										<tr>
											<td>&nbsp;</td>
											<td class="submitTD">
												<input id="remember" value="1" type="checkbox" name="zrememberme" />
												<label for="remember"><fmt:message key="${smallScreen?'rememberMeMobile':'rememberMe'}"/></label>
												<input type="submit" class="ZLoginButton DwtButton" value="<fmt:message key="login"/>" />
												<input name="Dong y" class="ZLoginButton DwtButton" id="btn_login_by_token" type="button" value="Đăng nhập bằng Token" style="">    <!-- Ecoit -->
											</td>
										</tr>
						</c:otherwise>
					</c:choose>
					<c:if test="${empty param.virtualacctdomain}">
					<tr <c:if test="${client eq 'socialfox'}">style='display:none;'</c:if>>
						<td colspan="2"><hr/></td>
					</tr>
					<tr <c:if test="${client eq 'socialfox'}">style='display:none;'</c:if>>
						<td>
							<label for="client"><fmt:message key="versionLabel"/></label>
						</td>
						<td>
							<div class="positioning">
								<c:choose>
									<c:when test="${client eq 'socialfox'}">
										<input type="hidden" name="client" value="socialfox"/>
									</c:when>
									<c:otherwise>
										<select id="client" name="client" onchange="clientChange(this.options[this.selectedIndex].value)">
											<option value="preferred" <c:if test="${client eq 'preferred'}">selected</c:if> > <fmt:message key="clientPreferred"/></option>
											<option value="advanced" <c:if test="${client eq 'advanced'}">selected</c:if>> <fmt:message key="clientAdvanced"/></option>
											<option value="standard" <c:if test="${client eq 'standard'}">selected</c:if>> <fmt:message key="clientStandard"/></option>
											<option value="mobile" <c:if test="${client eq 'mobile'}">selected</c:if>> <fmt:message key="clientMobile"/></option>
                                            <c:if test="${touchLoginPageExists}">
    											<option value="touch" <c:if test="${client eq 'touch'}">selected</c:if>> <fmt:message key="clientTouch"/></option>
                                            </c:if>
										</select>
									</c:otherwise>
								</c:choose>
<script TYPE="text/javascript">
	document.write("<a href='#' onclick='showWhatsThis()' id='ZLoginWhatsThisAnchor'><fmt:message key="whatsThis"/><"+"/a>");
</script>
									<div id="ZLoginWhatsThis" class="ZLoginInfoMessage" style="display:none;"><fmt:message key="clientWhatsThisMessage"/></div>
									<div id="ZLoginUnsupported" class="ZLoginInfoMessage" style="display:none;"><fmt:message key="clientUnsupported"/></div>
								</div>
							</td>
						</tr>
					</c:if>
					</table>
			</form>
			</div>
			<div class="decor1"></div>
		</div>

		<div class="${smallScreen?'Footer-small':'Footer'}">
			<div id="ZLoginNotice" class="legalNotice-small"><fmt:message key="clientLoginNotice"/></div>
			<div class="copyright">
			<c:choose>
				<c:when test="${mobileSupported}">
							<fmt:message bundle="${zhmsg}" key="splashScreenCopyright"/>
				</c:when>
				<c:otherwise>
							<fmt:message key="splashScreenCopyright"/>
				</c:otherwise>
			</c:choose>
			</div>
		</div>
		<div class="decor2"></div>
	</div>
<script>

<jsp:include page="/js/skin.js">
	<jsp:param name="templates" value="false" />
	<jsp:param name="client" value="advanced" />
	<jsp:param name='servlet-path' value='/js/skin.js' />
</jsp:include>
var link = document.getElementById("bannerLink");
if (link) {
	link.href = skin.hints.banner.url;
}

<c:if test="${smallScreen && ua.isIE}">		/*HACK FOR IE*/
	var resizeLoginPanel = function(){
		var panelElem = document.getElementById('ZLoginPanel');
		if(panelElem && !panelElem.style.maxWidth) { if(document.body.clientWidth >= 500) { panelElem.style.width="500px";}else{panelElem.style.width="90%";} }
	}
	resizeLoginPanel();
	if(window.attachEvent){ window.attachEvent("onresize",resizeLoginPanel);}
</c:if>

// show a message if they should be using the 'standard' client, but have chosen 'advanced' instead
function clientChange(selectValue) {
	var useStandard = ${useStandard ? 'true' : 'false'};
	useStandard = useStandard || (screen && (screen.width <= 800 && screen.height <= 600));
	var div = document.getElementById("ZLoginUnsupported");
	if (div)
	div.style.display = ((selectValue == 'advanced') && useStandard) ? 'block' : 'none';
}

// if they have JS, write out a "what's this?" link that shows the message below
function showWhatsThis() {
	var div = document.getElementById("ZLoginWhatsThis");
	div.style.display = (div.style.display == "block" ? "none" : "block");
}

function onLoad() {
	var loginForm = document.loginForm;
	if (loginForm.username) {
		if (loginForm.username.value != "") {
			loginForm.password.focus(); //if username set, focus on password
		}
		else {
			loginForm.username.focus();
		}
	}
	clientChange("${zm:cook(client)}");
    //check if the login page is loaded in the sidebar.
    if (navigator.mozSocial) {
        //send a ping so that worker knows about this page.
        navigator.mozSocial.getWorker().port.postMessage({topic: "worker.reload", data: true});
        //this page is loaded in firefox sidebar so listen for message from worker.
        navigator.mozSocial.getWorker().port.onmessage = function onmessage(e) {
            var topic = e.data.topic;
            if (topic && topic == "sidebar.authenticated") {
                window.location.href = "/public/launchSidebar.jsp";
            }
        };
    }
}

</script>
</body>
</html>a
