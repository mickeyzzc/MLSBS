#!/bin/env python
import os,smtplib,mimetypes,ConfigParser,re,base64,os.path,sys
from hashlib import sha256
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
def my_encrypt(key, pwd):
	b = bytearray(str(pwd).encode("utf-8"))
	n = len(b)
	c = bytearray(n*2)
	j = 0
	for i in range(0, n):
		b1 = b[i]
		b2 = b1 ^ key
		c[j] = b2 % 16 + 65
		c[j+1] = b2 // 16 + 65
		j = j+2
	return c.decode("utf-8")
def my_decrypt(key,pwd):
	c = bytearray(str(pwd).encode("utf-8"))
	n = len(c)
	if n % 2 != 0:
		return ""
	n = n // 2
	b = bytearray(n)
	j = 0
	for i in range(0, n):
		b2 = (c[j+1]-65) * 16 + (c[j]-65)
		b1 = b2 ^ key
		b[i]=b1
		j = j + 2
	try:
		return b.decode("utf-8")
	except:
		return False
def my_mail_config():
	try:
		config=ConfigParser.ConfigParser()
		confile=os.path.join(sys.path[0],'pyconfig.conf')
		with open(confile,'r') as cfgfile:
			config.readfp(cfgfile)
			USERNAME=config.get('email','username')
			PASSWD=base64.b64decode(config.get('email','passwd'))
			SMTP=config.get('email','smtp')
			return (USERNAME,PASSWD,SMTP)
	except Exception,errmsg:
		print "No config : %s" % errmsg
		return False
		
def my_send_mail(mailist,subject,msg,ssl=None,filename=None):
	USERNAME,PASSWD,SMTP = my_mail_config()
	MAIL_LIST = re.split(',|;',mailist)
	try:
		message = MIMEMultipart()
		message.attach(MIMEText(msg))
		message["Subject"] = subject
		message["From"] = USERNAME
		message["To"] = ";".join(MAIL_LIST)
		if filename != None and os.path.exists(filename):
			ctype,encoding = mimetypes.guess_type(filename)
			if ctype is None or encoding is not None:
				ctype = "application/octet-stream"
			maintype,subtype = ctype.split("/",1)
			attachment = MIMEImage((lambda f: (f.read(), f.close()))(open(filename, "rb"))[0], _subtype = subtype)
			attachment.add_header("Content-Disposition", "attachment", filename = os.path.split(filename)[1])
			message.attach(attachment)
			
		if ssl = None:
			s = smtplib.SMTP()
		else:
			s = smtplib.SMTP_SSL()
		s.connect(SMTP)
		s.login(USERNAME,PASSWD)
		s.sendmail(USERNAME,MAIL_LIST,message.as_string())
		s.quit()
		
		return True
	except Exception,errmsg:
		print "Send mail failed to : %s" % errmsg
		return False
	
if __name__ == "__main__":
	from optparse import OptionParser
	parser = OptionParser()
	parser.add_option("-t","--to",dest="MAIL_LIST",default='mickey_zzc@126.com',help="Send to someone")
	parser.add_option("-s","--subject",dest="subject",default='Test Mail',help="Subject of Mail")
	parser.add_option("-m","--msg",dest="msg",default='Test Mail Message',help="Text")
	parser.add_option("-f","--file",dest="filename",default=None,help="File")
	parser.add_option("-S","--SSL",dest="ssl",default=None,help="Add ssl")
	(options,args) = parser.parse_args()
	print 'options: %s , args: %s ' % (options,args)
	if my_send_mail(options.MAIL_LIST , options.subject , options.msg , options.ssl , options.filename):
		print "OK"
	else:
		print "No mail to send"
			
