

#-----------------------------------------------------------
# ステータスコードを取得
#-----------------------------------------------------------
sub do_get_status{

# 宣言
my ($url) = @_;
our($agent);
use LWP::UserAgent;

# 無限ループを禁止
if($agent =~ /libwww-perl/ || $agent eq ""){ return; }

# URLをデスケープ
($url) = Mebius::Descape("",$url);

# 記録
&access_log("GETSTATUS","GetUrl : $url");

my $ua = new LWP::UserAgent();
my $head = $ua->head($url);

my $code = $head->code();
my $message = $head->message();

return($code,$message);

}

1;
