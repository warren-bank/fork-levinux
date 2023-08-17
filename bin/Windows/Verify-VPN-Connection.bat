@echo off

set url="http://ipv4.icanhazip.com/"
set proxy="socks5h://localhost:1080"

set curl_opts=--silent %url%

FOR /F "tokens=* USEBACKQ" %%F IN (`curl %curl_opts%`) DO (set ip_real=%%F)
FOR /F "tokens=* USEBACKQ" %%F IN (`curl --proxy %proxy% %curl_opts%`) DO (set ip_vpn=%%F)

echo real IP: %ip_real%
echo VPN  IP: %ip_vpn%
echo.

if not defined ip_real goto :bad_real
if "%ip_real%"=="" goto :bad_real

if not defined ip_vpn goto :bad_vpn
if "%ip_vpn%"=="" goto :bad_vpn

if "%ip_real%"=="%ip_vpn%" (
  echo ERROR: VPN is not working
) else (
  echo SUCCESS: VPN is working
)
goto :done

:bad_real
  echo ERROR: Bad internet connection
  goto :done

:bad_vpn
  echo ERROR: VPN is not ready
  goto :done

:done
  echo.
  pause
