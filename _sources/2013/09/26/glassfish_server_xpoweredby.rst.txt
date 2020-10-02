GlassFish v3.1.2.2でServerヘッダとX-Powered-Byヘッダを返さないようにする
=================================================================================

まずはServerヘッダ。

.. sourcecode:: sh

   asadmin create-jvm-option -Dproduct.name=

JVMオプションなので設定の反映にはGlassFishを再起動する必要があります。

次、X-Powered-Byヘッダ。

.. sourcecode:: sh

   asadmin set configs.config.server-config.network-config.protocols.protocol.http-listener-1.http.xpowered-by=false

こちらは設定は則反映されます。

で、JSP。
default-web.xmlでJspServletを設定しているところを見つけます。
でフォルトではxpoweredByがtrueに設定されているのでこれをfalseにします。

.. sourcecode:: xml

   <servlet>
     <servlet-name>jsp</servlet-name>
     <servlet-class>org.apache.jasper.servlet.JspServlet</servlet-class>
     <init-param>
       <param-name>xpoweredBy</param-name>
       <param-value>false</param-value>
     </init-param>

最後にJSF。
web.xmlでFacesServletを設定する際にinit-paramでcom.sun.faces.sendPoweredByHeaderをfalseに設定すると良いようです。
試してない。


.. author:: default
.. categories:: none
.. tags:: Java, GlassFish, JSP, JSF, Security
.. comments::
