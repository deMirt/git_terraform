#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<OEF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
<meta charset="utf-8">
<title> Mikalayenka Dzmitry</title>
<meta name="description" content="Mikalayenka Dzmirty">
<meta name="keywords" content="Demo,intro,AWS,devOps">
<style type="text/css">
#layer1 {
 position: relative;
 z-index:11;
 background: #888;
 width: 60%;
 padding: 10px;
 border-radius: 10px 10px 0px 0px;
 opacity: 0.95;
}

 #layer2{
 position: relative;
 z-index:11;
 background: #BBB;
 width: 60%;
 padding: 10px;
 opacity: 0.95;
 }
 #layer3 {
  position: relative;
  z-index:11;
  background: #888;
  width: 60%;
  padding: 10px;
  border-radius: 0px 0px 10px 10px;
  opacity: 0.95;
 }
 #bg {
   position: absolute;
   z-index: 1;
   left: -10px;
   top: -10px;
   right: -10px;
   bottom: -10px;
   filter: blur(3px);
   background: url(https://raw.githubusercontent.com/deMirt/git_terraform/master/gb.jpg);
   }
  </style>
</head>
<body>
<div id="bg"></div>
  <center>
    <br>
    <br>
  <div align="center" id="layer1" ><H2><font color="gold"> Mikalayenka Dzmirty</font></h2></div>
<div align="left" id="layer2">
  <span>
    Owner: <font color="red">Mikalayenka Dzmirty</font></span><br>
  <span> My Curriculum Vitae : link </span><br>
  <span> Linkedin Profile : <a href="https://www.linkedin.com/in/dmitry-mikalayenko-263351a0/">linkedin.com<a></span><br>
  <span> My email : demirtmeister@gmail.com </span>
</div>
<div align="left" id="layer2" >
%{ for x in digits ~}
Starting count ...  ${x} !!! <br>
%{ endfor ~}<br>
Server PrivateIP : <font color="blue"> $myip </font> <br>
</div>
<div align="left" id="layer3" >
Build by Terraform <br>
Region : ${region} <br>
info: ${info} <br>
version : 2.0
</div>
</center>
</body>
</html>
OEF
sudo service httpd start
chkconfig httpd on
