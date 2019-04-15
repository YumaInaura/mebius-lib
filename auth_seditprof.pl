#-----------------------------------------------------------
# アカウント編集のコア処理
#-----------------------------------------------------------

sub seditprof{

# 局所化
my($line,$bkline,$max_bkup,$bki);
our($addr,$xip,$date,$cnumber,%in);

# バックアップの最大行数
$max_bkup = 5;

# ファイル定義
my($file) = @_;
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("値を設定してください。"); }

# バックアップを開く
$bkline = qq($in{'prof'}<>$xip<>$date<>$cnumber<>$addr<>\n);
open(PROF_BKUP_IN,"${int_dir}_id/$file/${file}_bkup.cgi");
while(<PROF_BKUP_IN>){
$bki++;
if($bki < $max_bkup){ $bkline .= $_; }
}
close(PROF_BKUP_IN);

# 書き込み内容
$line = <<"EOM";
$ppkey<>$ppaccount<>$pppass<>$ppsalt<>$ppfirsttime<>$ppblocktime<>$pplasttime<>$ppadlasttime<>
$ppname<>$ppmtrip<>$ppcolor1<>$ppcolor2<>$ppprof<>
$ppocomment<>$ppodiary<>$ppobbs<>$pposdiary<>$pposbbs<>$pporireki<>
$ppencid<>$ppenctrip<>
$pplevel<>$pplevel2<>$ppsurl<>$ppadmin<>$ppchat<>$ppreason<>
$ppemail<>$ppmlpass<>
EOM

# ファイルに書き込み
open(PROF_OUT,">${int_dir}_id/$file/$file.cgi");
print PROF_OUT $line; 
close(PROF_OUT);
chmod($logpms,"${int_dir}_id/$file/$file.cgi");

}

1;

