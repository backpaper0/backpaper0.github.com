GlassFish 3.1.2.2でCookieにsecure属性とhttpOnly属性をつける
=================================================================

何もしなくてもhttpOnly属性は付いてる感じですが、それはGrizzlyの機能なのでしょうかね。
それはそれでまた調べておくことにします。


プログラムで設定する
---------------------------

javax.servlet.SessionCookieConfig_ を使用します。

.. sourcecode:: java

    package example;

    import java.util.Set;
    import javax.servlet.ServletContainerInitializer;
    import javax.servlet.ServletContext;
    import javax.servlet.ServletException;
    import javax.servlet.SessionCookieConfig;

    public class CookieSettings implements ServletContainerInitializer {

        @Override
        public void onStartup(Set<Class<?>> c, ServletContext ctx) throws ServletException {
            SessionCookieConfig scc = ctx.getSessionCookieConfig();
            scc.setHttpOnly(true);
            scc.setSecure(true);
        }
    }


GlassFish Server Deployment Descriptorで設定する
------------------------------------------------------

`cookie-properties - Oracle GlassFish Server 3.1 Application Deployment Guide`_ を参照。

.. sourcecode:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE glassfish-web-app PUBLIC
      "-//GlassFish.org//DTD GlassFish Application Server 3.1 Servlet 3.0//EN"
      "http://glassfish.org/dtds/glassfish-web-app_3_0-1.dtd">
    <glassfish-web-app error-url="">
     <session-config>
      <cookie-properties>
       <property name="cookieSecure" value="true"/>
       <property name="cookieHttpOnly" value="true"/>
      </cookie-properties>
     </session-config>
    </glassfish-web-app>


.. _javax.servlet.SessionCookieConfig: http://docs.oracle.com/javaee/6/api/javax/servlet/SessionCookieConfig.html
.. _cookie-properties - Oracle GlassFish Server 3.1 Application Deployment Guide: http://docs.oracle.com/cd/E18930_01/html/821-2417/beash.html#scrolltoc







.. author:: default
.. categories:: none
.. tags:: Java, GlassFish, Cookie, Security
.. comments::
