#!/usr/bin/env python
#encoding=utf-8
import sys,ftplib,os.path
def ftp_connect(ftphost,ftpost,ftpname,ftpwd):
    myftp=ftplib.FTP()
    myftp.set_pasv(1) if False else myftp.set_pasv(0)
    try:
        myftp.connect(ftphost,ftpost,10)
        print 'FTP connect is success.'
    except Exception, e:
        print >> sys.stderr, "conncet failed - %s" % e
        return (0,'conncet failed')
    else:
        try:
            myftp.login(ftpname, ftpwd)
            print 'login success'
        except Exception, e:
            print >> sys.stderr, "login failed - %s" % e
            return (0,'login failed')
        else:
            print 'return 1'
            return (1,myftp)
    
def l_r_diff(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata):
    mftmp=ftp_connect(ftphost,ftpost,ftpname,ftpwd)
    if mftmp[0]!=1:
        print mftmp[1]
        sys.exit()
    myftp=mftmp[1]
    rdata=splitpath(remotedata)
    #myftp.retrlines("MLSD",None)
    myftp.cwd(rdata[0])
    rsize=0L
    lsize=0L
    try:
        rsize=myftp.size(rdata[1])
    except:
        myftp.voidcmd('TYPE I')
        try:
            rsize=myftp.size(rdata[1])
        except:
            pass
    if (rsize==None):
        rsize=0L
    if os.path.exists(localdata):
        lsize=os.stat(localdata).st_size
    else:
        print "%s doesn't exists" %localdata
        return
    print('LocalFile size: %d, RemoteFile size: %d' % (lsize,rsize))
    return (myftp,lsize,rdata[1],rsize)
    
def splitpath(remotepath):
    position=remotepath.rfind('/')
    return (remotepath[:position+1],remotepath[position+1:])

def ftp_up(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata):
    myftp,lsize,rdata,rsize=l_r_diff(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata)
    if (lsize==rsize):
        print 'remote filesize is equal with local'
        return
    if(lsize>rsize):
        localfile=open(localdata,'rb')
        localfile.seek(rsize)
        myftp.voidcmd('TYPE I')
        datasock=''
        esize=''
        try:
            datasock,esize=myftp.ntransfercmd("STOR "+rdata,rsize)
        except Exception, e:
            print >>sys.stderr, '----------ftp.ntransfercmd-------- : %s' % e
            return
        tmpsize=rsize
        while True:
            buf=localfile.read(1024*1024)
            if not len(buf):
                print '\rNo data break'
                break
            datasock.sendall(buf)
            tmpsize+=len(buf)
            print '\b'*30,'uploading %.2f%%'%(float(tmpsize)/lsize*100),
            if tmpsize==lsize:
                print '\rfile size equal break'
                break
        datasock.close()
        print 'close data handle'
        localfile.close()
        print 'close local file handle'
        myftp.voidcmd('NOOP')
        print 'keep alive cmd success'
        myftp.voidresp()
        print 'No loop cmd'
        myftp.quit()

def ftp_download(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata):
    myftp,lsize,rdata,rsize=l_r_diff(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata)
    if (lsize>=rsize):
        print 'local file is bigger or equal remote file'
        return
    tmpsize=rsize
    myftp.voidcmd('TYPE I')
    datasock=myftp.transfercmd('RETR '+rdata,lsize)
    localfile=open(localdata,'ab')
    while True:
        buf=datasock.recv(1024 * 1024)
        if not buf:
            break
        localfile.write(buf)
        tmpsize+=len(buf)
        print '\b'*30,'uploading %.2f%%'%(float(tmpsize)/rsize*100),
    localfile.close()
    myftp.voidcmd('NOOP')
    myftp.voidresp()
    datasock.close()
    myftp.quit()

if __name__ == "__main__":
    from optparse import OptionParser
    parser = OptionParser()
    optlist=(("-t","--type","ftp_type",'upload',"Host of FTP"),("-H","--host","ftp_host","127.0.0.1","Host of FTP"),
             ("-P","--post","ftp_post",'21',"Post of FTP"),("-u","--username","ftp_user",'anonymous',"anonymous"),("-p","--password","ftp_password",None,"password"),
             ("-l","--localfile","localfile",None,"localfile"),("-r","--remotefile","remotefile",None,"remotefile"))
    for opt in optlist:
         parser.add_option(opt[0],opt[1],dest=opt[2],default=opt[3],help=opt[4])
    (options,args) = parser.parse_args()
    def mftp(ftype,ftphost,ftpost,ftpname,ftpwd,remotedata,localdata):
        if ftype=='upload':
            ftp_up(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata)
            print "UPLOAD OK"
        elif ftype=='download':
            ftp_download(ftphost,ftpost,ftpname,ftpwd,remotedata,localdata)
            print "DOWNLOAD OK"
        else:
            print "FTP TYPE IS ERROR"
    mftp(options.ftp_type , options.ftp_host , options.ftp_post , options.ftp_user , options.ftp_password, options.remotefile, options.localfile)