#!/usr/bin/env python
# -*- coding:utf-8 -*-
import smtplib, mimetypes, ConfigParser, re, base64, os.path, sys
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
def my_encrypt(key, pwd):
    b = bytearray(str(pwd).encode("utf-8"))
    n = len(b)
    c = bytearray(n * 2)
    j = 0
    for i in range(0, n):
        b1 = b[i] ^ len(key)
        c[j] = b1 % 16 + 65
        c[j + 1] = b1 // 16 + 65
        j = j + 2
    return c.decode("utf-8")
def my_decrypt(key, pwd):
    c = bytearray(str(pwd).encode("utf-8"))
    n = len(c)
    if n % 2 != 0:
        return ""
    n = n // 2
    b = bytearray(n)
    j = 0
    for i in range(0, n):
        b1 = (c[j + 1] - 65) * 16 + (c[j] - 65)
        b[i] = b1 ^ len(key)
        j = j + 2
    try:
        return b.decode("utf-8")
    except Exception, errmsg:
        print "Decode err : %s" % errmsg
        return False
def my_mail_config(pwd=None):
    try:
        config = ConfigParser.ConfigParser()
        confile = os.path.join(sys.path[0], 'sendmail.conf')
        with open(confile, 'r') as cfgfile:
            config.readfp(cfgfile)
            USERNAME = config.get('email', 'username')
            SMTP = config.get('email', 'smtp')
            if pwd is None:
                PASSWD = my_decrypt(USERNAME, base64.b64decode(config.get('email', 'passwd')))
                return (USERNAME, PASSWD, SMTP)
            else:
                config.set('email', 'passwd', base64.b64encode(my_encrypt(USERNAME, pwd)))
                config.write(open(confile, 'w'))
                print "email.passwd's encrypt: %s" % config.get('email', 'passwd')
                return True
    except Exception, errmsg:
        print "No config : %s" % errmsg
        return False
        
def sys_pipe_stdin():
    STDIN_MSG = {}
    STDIN_MSG = sys.stdin.read()
    '''sys.stdin.close()'''
    if STDIN_MSG:
        return STDIN_MSG
    else:
        return "Test Mail Message"
    
def my_send_mail(mailist, subject, msg, ssl=False, filename=None):
    USERNAME, PASSWD, SMTP = my_mail_config()
    MAIL_LIST = re.split(',|;', mailist)
    try:
        message = MIMEMultipart()
        message.attach(MIMEText(msg))
        message["Subject"] = subject
        message["From"] = USERNAME
        message["To"] = ";".join(MAIL_LIST)
        if filename != None and os.path.exists(filename):
            ctype, encoding = mimetypes.guess_type(filename)
            if ctype is None or encoding is not None:
                ctype = "application/octet-stream"
            maintype, subtype = ctype.split("/", 1)
            attachment = MIMEImage((lambda f: (f.read(), f.close()))(open(filename, "rb"))[0], _subtype=subtype)
            attachment.add_header("Content-Disposition", "attachment", filename=os.path.split(filename)[1])
            message.attach(attachment)
        if ssl == False:
            s = smtplib.SMTP()
        else:
            s = smtplib.SMTP_SSL()
        s.connect(SMTP)
        s.login(USERNAME, PASSWD)
        s.sendmail(USERNAME, MAIL_LIST, message.as_string())
        s.quit()
        return True
    except Exception, errmsg:
        print "Send mail failed to : %s" % errmsg
        return False
    
if __name__ == "__main__":
    from optparse import OptionParser
    from optparse import OptionGroup
    parser = OptionParser(usage="%prog [-f] [-q]", version="%prog 1.2")
    parser.add_option("-s", "--ssl", dest="ssl", action="store_false", default=True, help="Use ssl")
    parser.add_option("-e", "--encrypt", dest="pwd", default=None, help="Encrypt passward and write in config . eg: -e password")
    sendmailgroup = OptionGroup(parser, "The extension command",
            "The extension command is used to send mail .",)
    sendmailgroup.add_option("-t", "--to", dest="recipient", default=None, help="Send to Someone,or lists")
    sendmailgroup.add_option("-S", "--subject", dest="subject", default='Test Mail', help="Subject of Mail")
    sendmailgroup.add_option("-m", "--msg", dest="msg", default=None, help="Mail Text")
    sendmailgroup.add_option("-f", "--file", dest="attachment", default=None, help="The attachment")
    parser.add_option_group(sendmailgroup)
    (options, args) = parser.parse_args()
    '''print 'options: %s , args: %s ' % (options,args)'''
    if options.recipient and options.subject:
        try:
            TMP_MSG = sys_pipe_stdin()
            ALL_MSG = str(TMP_MSG)
            if options.msg :
                ALL_MSG = str(options.msg) + "\n" + str(TMP_MSG)
            my_send_mail(options.recipient , options.subject , ALL_MSG , options.ssl , options.attachment)
            print "Send mail is OK"
        except Exception, errmsg:
            print "Send mail err : %s" % errmsg
    elif options.pwd:
        my_mail_config(options.pwd)
    else:
        print parser.print_help()