#!/bin/env python
import os,smtplib,mimetypes,ConfigParser,re
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
def mailconfig():
    try:
        config=ConfigParser.ConfigParser()
        with open('myconfig.txt','r') as cfgfile:
            config.readfp(cfgfile)
            USERNAME=config.get('email','username')
            PASSWD=config.get('email','passwd')
            SMTP=config.get('email','smtp')
            return (USERNAME,PASSWD,SMTP)
    except:
        print "no config"
        return ("test@ecardtek.com","ect123","smtp.exmail.qq.com")
        
def mysendmail(mailist,subject,msg,filename=None):
    USERNAME,PASSWD,SMTP = mailconfig()
    MAIL_LIST = re.split(',|;',mailist)
    try:
        message = MIMEMultipart()
        message.attach(MIMEText(msg))
        message["Subject"] = subject
        message["From"] = USERNAME
        message["To"] = ";".join(MAIL_LIST)
#	message["To"] = MAIL_LIST
        if filename != None and os.path.exists(filename):
            ctype,encoding = mimetypes.guess_type(filename)
            if ctype is None or encoding is not None:
                ctype = "application/octet-stream"
            maintype,subtype = ctype.split("/",1)
            attachment = MIMEImage((lambda f: (f.read(), f.close()))(open(filename, "rb"))[0], _subtype = subtype)
            attachment.add_header("Content-Disposition", "attachment", filename = filename)
            message.attach(attachment)
            
        s = smtplib.SMTP()
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
    parser.add_option("-t","--to",dest="MAIL_LIST",default='mickeyzheng@ecardtek.com',help="Send to someone")
    parser.add_option("-s","--subject",dest="subject",default='Test Mail',help="Subject of Mail")
    parser.add_option("-m","--msg",dest="msg",default='Test Mail Message',help="Text")
    parser.add_option("-f","--file",dest="filename",default=None,help="File")
    (options,args) = parser.parse_args()
    print 'options: %s , args: %s ' % (options,args)
    if mysendmail(options.MAIL_LIST , options.subject , options.msg , options.filename):
        print "OK"
    else:
        print "No mail to send"
            
