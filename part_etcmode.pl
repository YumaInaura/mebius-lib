package main;

#-----------------------------------------------------------
# 色々なモード
#-----------------------------------------------------------
sub etc_mode{
our($mode);
if($mode eq "random"){ &bbs_randomjump(); }
elsif($mode eq "my") { &bbs_old_mypage(); }
else{ &error("モードがありません。"); }
}


#-----------------------------------------------------------
# 旧マイページをリダイレクト
#-----------------------------------------------------------
sub bbs_old_mypage{ Mebius::Redirect("","http://$server_domain/_main/my.html",301); }

#-----------------------------------------------------------
# ランダムな記事にジャンプ
#-----------------------------------------------------------
sub bbs_randomjump{

$css_text .= qq(.body1{padding-bottom:4em});
my($cnt);

# 現在の記事数を取得
open(IN,"<","$nowfile");
while(<IN>){ $cnt++; }
close(IN);

# 飛ぶ記事をランダムで選ぶ
open(IN,"<","$nowfile");
while(<IN>){
my($no,$none,$none,$none,$none,$none,$key) = split(/<>/,$_); 
if($key eq "1" || $key eq "5"){
if(rand($cnt) < 1){ $jump = $no; last; }
}
$cnt--;
}
close(IN);

$sub_title = "記事ジャンプ";
$jump_url = "/_$moto/${jump}.html";
$meta_robots = qq(<meta name="robots" content="noindex,follow">);

my $print = <<"EOM";
<div class="body1">
<a href="/_$moto/${jump}.html">ランダムな記事へジャンプする</a>
</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 掲示板の閉鎖
#-----------------------------------------------------------

sub bbs_heisa_view{

# URL調整
my $no = $in{'no'};
my $viewno = "$no.html" if($no ne "");

&error("この掲示板は閉鎖中です。","410 Gone");
}

1;



1;
