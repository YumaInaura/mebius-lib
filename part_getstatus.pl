

#-----------------------------------------------------------
# �X�e�[�^�X�R�[�h���擾
#-----------------------------------------------------------
sub do_get_status{

# �錾
my ($url) = @_;
our($agent);
use LWP::UserAgent;

# �������[�v���֎~
if($agent =~ /libwww-perl/ || $agent eq ""){ return; }

# URL���f�X�P�[�v
($url) = Mebius::Descape("",$url);

# �L�^
&access_log("GETSTATUS","GetUrl : $url");

my $ua = new LWP::UserAgent();
my $head = $ua->head($url);

my $code = $head->code();
my $message = $head->message();

return($code,$message);

}

1;
