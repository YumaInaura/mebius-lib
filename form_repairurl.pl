#-----------------------------------------------------------
# リダイレクト専用フォームを取得
#-----------------------------------------------------------
sub get_repairform{

# 局所化
my($unwork_url,$type,$type2) = @_;
my($form,$hit,$domain,$redirected_flag);
our($alocal_mode,$referer,$int_dir);


# リファラがない場合リターン
if($referer eq ""){ return; }

# CSS定義
$css_text .= qq(
.repairurl{padding:1em;border:solid 1px #f00;margin:0em 0em 1em 0em;}
);

# Javascriptの場合の「現在のＵＲＬ（リンク切れ）」を定義
if($type2 eq "javascript"){ $unwork_url = "<Location.Href>"; }

	# ドメインチェック
	foreach(@domains){
		$hit += ($referer =~ s/^http:\/\/($_)\/_([a-z0-9]+)\/(k|)([0-9]+)([0-9_]+|_data|_memo|)\.html([0-9\-\,]+|)$/$&/);
		$domain = $1;
	}

	# URLが正規のものでなかった場合、リターンして普通にエラーを表示
	if(!$hit || $domain eq ""){ return; }

# 調整
$repair_url = $referer;

# URL のエンコード
my $enc_repair_url = &Mebius::Encode("",$repair_url);
my $enc_unwork_url = &Mebius::Encode("",$unwork_url);

	# リダイレクト（自動リンク切れ修正）
	if(!$k_access && $unwork_url && $repair_url){
		if($type2 eq "javascript"){ $enc_unwork_url = "<Location.Href>"; }
		($redirected_flag) = &repair_redirect("http://$domain/_main/?mode=repairurl&type=$type&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1",$repair_url,$unwork_url,$type2);
	}

# 管理者表示のテキスト
my($navigation_text,$method);
$method = "post";
if($myadmin_flag >= 5 && !$redirected_flag){
$navigation_text .= qq(<br><br>);
$navigation_text .= qq($date<br><br>);
if($redirected_flag){ $navigation_text .= qq(<strong class="red">リダイレクトをブロックしました。</strong><br>); }
if($referer){ $navigation_text .= qq(<strong class="red">リファラ（元ページ）： $referer</strong><br>); }
$navigation_text .= qq(<strong class="red">ＵＲＬ（リンク切れ）： $unwork_url</strong><br>);
$navigation_text .= qq(<strong class="red">リダイレクト先： http://$domain/_main/?mode=repairurl&type=$type&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1</strong><br>);
$method = "get";
}

return($form,$redirected_flag);

}

#-----------------------------------------------------------
# 自動リンク切れ修正ページにリダイレクト
#-----------------------------------------------------------
sub repair_redirect{

# 局所化
my($line,$i,$file,$flag);
my($redirect_url,$repair_url,$unwork_url,$type2) = @_;

# 履歴ファイル
$file = "${int_dir}_backup/repair_redirect_history.cgi";

# 追加する行
$line .= qq($repair_url<>$time<>\n);

# リダイレクト履歴を開く
open(REDIRECT_HISTORY_IN,"$file");
while(<REDIRECT_HISTORY_IN>){
$i++;
chomp;
my($repairurl2,$lasttime) = split(/<>/);
if($lasttime + 2 >= $time){ $flag = 1; }
if($repairurl2 eq $repair_url && $lasttime + 5 >= $time){ $flag = 1; }
if($i < 10){ $line .= qq($repairurl2<>$lasttime<>\n); }
}
close(REDIRECT_HISTORY_IN);

# リダイレクト履歴を更新
if(!$flag){
open(REDIRECT_HISTORY_OUT,">$file");
print REDIRECT_HISTORY_OUT $line;
close(REDIRECT_HISTORY_OUT);
chmod($logpms,file);
}

# リダイレクト (Javascript)
if(!$flag && $type2 eq "javascript"){
$redirect_url =~ s/$unwork_url/'\+location\.href\+'/g;
$head_javascript .= qq(
<script type="text/javascript">
<!--
setTimeout("link()", 0);
function link(){
var url = ('$redirect_url');
location.href=(url);
}
-->
</script>
);
}


# リダイレクト (ＣＧＩ)
if(!$flag && $type2 ne "javascript"){ &Mebius::Redirect("",$redirect_url); }

return($flag);

}


# フォーム定義 (ＰＣ版)
#if($type eq "pc" && !$redirected_flag){
#$form = qq(
#<form action="http://$domain/_main/" method="$method" class="repairurl"$sikibetu><div>
#<strong class="red">リンク切れの修正</strong<br$xclose><br$xclose>
#下のボタンを押すと、元ページでのリンク切れを修正できます。<br$xclose>
#( 例： <a href="http://aurasoul.mb2.jp/_qst/2352.html">http://aurasoul.mb2.jp/_qst/2352.html</a>　→　<del>ttp://aurasoul.mb2.jp/_qst/1.html</del> #)<br$xclose><br$xclose>
#ぜひ、リンク切れ修正にご協力ください。<br$xclose><br$xclose>
#<input type="hidden" name="mode" value="repairurl"$xclose>
#<input type="hidden" name="type" value="boad"$xclose>
#<input type="hidden" name="repair_url" value="$repair_url"$xclose>
#<input type="hidden" name="unwork_url" value="$unwork_url"$xclose>
#<input type="submit" name="action" value="元ページのリンク切れを修正する"$xclose>
#$navigation_text
#</div></form>
#);
#}

# フォームをJavaScirptで生成する場合
#if($type2 eq "javascript"){
#$form =~ s/(\n|\r)//g;
#$form =~ s(</)(<\\/)g;
#$form =~ s/$unwork_url/\'\+location\.href\+\'/g;
#$form = qq(
#<script type="text/javascript"><!--
#document.write('$form');
#// --></script>
#);
#}

1;


