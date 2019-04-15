
#-----------------------------------------------------------
# リダイレクト処理
#-----------------------------------------------------------
sub do_redirect{

my($url,$code) = @_;
our($requri);
#if($url eq ""){ &error("うまくリダイレクトできませんでした。"); }

# 汚染チェック
$url =~ s/(\n|\r)//g;

# リダイレクトを記録
&main::access_log("Redirect-old","http://$main::server_domain$main::requri → $url $code");

if($code eq "301"){ print "Status: 301 Moved Permanently\n"; }

print "Location: $url\n";
print "\n";

exit;

# リターン
return();

}


1;
