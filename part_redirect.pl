
#-----------------------------------------------------------
# ���_�C���N�g����
#-----------------------------------------------------------
sub do_redirect{

my($url,$code) = @_;
our($requri);
#if($url eq ""){ &error("���܂����_�C���N�g�ł��܂���ł����B"); }

# �����`�F�b�N
$url =~ s/(\n|\r)//g;

# ���_�C���N�g���L�^
&main::access_log("Redirect-old","http://$main::server_domain$main::requri �� $url $code");

if($code eq "301"){ print "Status: 301 Moved Permanently\n"; }

print "Location: $url\n";
print "\n";

exit;

# ���^�[��
return();

}


1;
