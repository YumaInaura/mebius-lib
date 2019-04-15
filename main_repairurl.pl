
use strict;
use Mebius::Referer;
use Mebius::Getstatus;
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# 「自動リンク切れ修正のリダイレクト発動」のための判定処理
#-----------------------------------------------------------
sub get_repairform{

# 局所化
my($type) = @_;
my($form,$hit,$domain,$redirected_flag,$repair_url,$enc_repair_url,$enc_unwork_url);
my($unwork_url,$referer_type,$referer_domain);
our($alocal_mode,$referer,$css_text,@domains,$myadmin_flag,$k_access,$date,$selfurl);

# 具体的な「リンク切れページ」の指定がない場合、REQUEST_URL から代入する
if($unwork_url eq "" && $selfurl){ $unwork_url = $selfurl; }

# 各種リターン
if($referer eq ""){ return(); }
if($unwork_url eq ""){ return(); }

	# リファラ元ＵＲＬのドメインチェック
	# → リファラ元ＵＲＬが修復対象のファイルかどうかを判定
	($referer_type,$referer_domain) = Mebius::Referer("Type",$referer);

	# URLが正規のものでなかった場合、リターンして普通にエラーを表示
	if($referer_type !~ /bbs-thread/){ return(); }

# 調整
$repair_url = $referer;

# URL のエンコード
($enc_repair_url) = Mebius::Encode("",$repair_url);
($enc_unwork_url) = Mebius::Encode("",$unwork_url);

	# リダイレクト（自動リンク切れ修正）
	if(!$k_access && $unwork_url && $repair_url){

		my $redirect_url = "http://$referer_domain/_main/?mode=repairurl&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1";
		($redirected_flag) = &repair_redirect($type,$redirect_url,$repair_url,$unwork_url);
	}

	# 管理者表示のテキスト
	my($navigation_text,$method);
		if($myadmin_flag >= 5 && !$redirected_flag){
		$navigation_text .= qq(<br><br>);
		$navigation_text .= qq($date<br><br>);
		if($redirected_flag){ $navigation_text .= qq(<strong class="red">リダイレクトをブロックしました。</strong><br>); }
		if($referer){ $navigation_text .= qq(<strong class="red">リファラ（元ページ）： $referer</strong><br>); }
		$navigation_text .= qq(<strong class="red">ＵＲＬ（リンク切れ）： $unwork_url</strong><br>);
		$navigation_text .= qq(<strong class="red">リダイレクト先： http://$domain/_main/?mode=repairurl&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1</strong><br>);
	}

return();

}

#-----------------------------------------------------------
# 自動リンク切れ修正ページにリダイレクト
#-----------------------------------------------------------
sub repair_redirect{

# 局所化
my($type,$redirect_url,$repair_url,$unwork_url) = @_;
my($line,$i,$file,$flag,$repair_history_handler,$blank);
our($time,$int_dir,$head_javascript,$myadmin_flag,$alocal_mode);

# 履歴ファイル
$file = "${int_dir}_backup/repair_redirect_history.cgi";

# 追加する行
$line .= qq($repair_url<>$time<>\n);

	# 同一ＵＲＬ内に対しての、リダイレクトのブランク
	if($alocal_mode){ $blank = 10 ; }
	elsif($myadmin_flag){ $blank = 2; }
	else{ $blank = 5; }

# リダイレクト履歴を開き、最近の履歴がある場合はリダイレクトを回避
open($repair_history_handler,"$file");
	while(<$repair_history_handler>){
		$i++;
		chomp;
		my($repairurl2,$lasttime) = split(/<>/);
		if($lasttime + 2 >= $time){ $flag = 1; }
		if($repairurl2 eq $repair_url && $lasttime + $blank >= $time){ $flag = 1; }
		if($i < 10){ $line .= qq($repairurl2<>$lasttime<>\n); }
	}
close($repair_history_handler);

# リダイレクト履歴を更新
if(!$flag){ Mebius::Fileout("",$file,$line); }

	# リダイレクトを設定
	if(!$flag){

		# Javascriptでリダイレクトさせる場合
		if($type =~ /Javascript/){
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

		# CGIでリダイレクトさせる場合
		else{
			Mebius::Redirect("",$redirect_url);
		}
	}

return($flag);

}

#-----------------------------------------------------------
# リンク切れ修正 ( 全てを get送信 から判定 )
#-----------------------------------------------------------
sub main_repairurl{

# 局所化
my($repair_domain,$unwork_original_url);
my($repair_type,$ad_url,$unwork_url_descape);
my($repair_url,$unwork_url,$analyze_error,$unwork_flag,$unwork_type);
our(%in,$auth_url,$myadmin_flag);

# リンク先、リンク元のＵＲＬを定義
$repair_url = $in{'repair_url'};
$unwork_url = $unwork_original_url = $in{'unwork_url'};

# 失敗時に管理者に表示する情報
if($myadmin_flag >= 5){ $analyze_error = qq(Repair-url $repair_url / Unwork-url $unwork_url); }

	# リンク切れＵＲＬのステータスコードをチェック
	my($status) = Mebius::Getstatus("",$unwork_url);
	if($status eq "404" || $status eq "403" || $status eq "410"){ $unwork_flag = 1; }
	else{ &rperror("このＵＲＬ ( $unwork_url ) はリンク切れしていません。$status $analyze_error",$unwork_url); }

	# 元ページのＵＲＬタイプを判定して修正処理へ
	my($repair_type_buf) = Mebius::Referer("Type",$repair_url);
	if($repair_type_buf =~ /bbs-thread/){ &repair_boad("",$repair_url,$unwork_url); }													# 掲示板の記事を修正
	else{ main::error("元ページのＵＲＬが不正です。$analyze_error",$unwork_url); }		# 修正タイプがない場合

# 成功した場合、リンク切れページにリダイレクト
Mebius::Redirect("",$unwork_original_url);

exit;

}

#-----------------------------------------------------------
# 掲示板記事のリンク切れを修正
#-----------------------------------------------------------
sub repair_boad{

# 局所化
my($type,$repair_url,$unwork_url) = @_;
my($change,$line,$rpkr_flag,@krline,$saveline,$plus,$thread_handler);
my($kr_handler,$threadfile,$krfile,$savefile,$repair_resnumber_flag,@renew_line);
my($init_directory) = Mebius::BaseInitDirectory();

# リンク切れＵＲＬのタイプを取得(レス番修正用)
my($unwork_type,$unwork_domain,$unwork_moto,$unwork_no,$unwork_resnumber) = Mebius::Referer("Type",$unwork_url);

# 掲示板記事の番号などを取得
my($repair_type_buf,$repair_domain,$repair_moto,$repair_no,$repair_resnumber) = Mebius::Referer("Type",$repair_url);

	# 修正元と修正先のＵＲＬが同じ場合、レス番修正モードを発動
	if($unwork_resnumber ne "" && $repair_domain eq $unwork_domain && $repair_moto eq $unwork_moto && $repair_no eq $unwork_no){
		$repair_resnumber_flag = 1;
	}

# 汚染チェック
$repair_moto =~ s/\W//g;
$repair_no =~ s/\D//g;
$repair_resnumber =~ s/\D//g;
if($repair_moto eq ""){ return(); }
if($repair_no eq ""){ return(); }

# 掲示板用のファイル名を取得
my($bbs_file) = Mebius::BBS::InitFileName(undef,$repair_moto);

# ファイル定義
my($threadfile) = Mebius::BBS::path({ Target => "thread_file" },$repair_moto,$repair_no);
	if(!$threadfile){ &rperror("修正先の記事が設定できません。",$unwork_url); }

$krfile = "$bbs_file->{'data_directory'}_kr_$repair_moto/${repair_no}_kr.cgi";
#$savefile = "${init_directory}_backup/_repairurl/${repair_moto}-${repair_no}-repairurl.cgi";

# ロック開始
&lock($repair_moto);

# ●掲示板の記事を開く
open($thread_handler,"+<",$threadfile) || &rperror("修正先のページが見つかりません。",$unwork_url) ;
flock($thread_handler,2);

# トップデータの処理
chomp(my $top = <$thread_handler>);
$saveline .= qq($top\n);
my($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$dd8,$juufuku_com,$posttime) = split(/<>/,$top);

	if($key eq "4" || $key eq "6" || $key eq "7"){
		close($thread_handler);
		&rperror("元ページも削除済みのため、実行できませんでした。",$unwork_url);
	}

# 記事メモを修正
($memo_body,$plus) = &repair_auto("",$memo_body,$unwork_url);
$change += $plus;
	#if($repair_resnumber_flag){ ($memo_body,$plus) = &repair_resnumber_auto("",$memo_body,$unwork_resnumber); }
$change += $plus;

# トップデータを追加
push @renew_line ,  qq($no<>$sub<>$res<>$key<>$res_pwd<>$t_res<>$d_delman<>$d_password<>$dd1<>$sexvio<>$dd3<>$dd4<>$memo_editor<>$memo_body<>$dd7<>$dd8<>$juufuku_com<>$posttime<>\n);

	# 記事を展開
	while(<$thread_handler>){
		$saveline .= $_;
		chomp;
		my($resnum,$number,$name,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2,@other_data2) = split(/<>/);
		my($com,$plus) = &repair_auto("Strike",$com,$unwork_url);

		$change += $plus;
		#if($repair_resnumber_flag){ ($com,$plus) = &repair_resnumber_auto("",$com,$unwork_resnumber); } 
		$change += $plus;
		push @renew_line , Mebius::add_line_for_file([$resnum,$number,$name,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2,@other_data2]);
	}

	# ファイル更新
	if($change){
		seek($thread_handler,0,0);
		truncate($thread_handler,tell($thread_handler));
		print $thread_handler @renew_line;
	}

close($thread_handler);

	# パーミッション変更
	if($change){
		Mebius::Chmod(undef,$threadfile);
	}

# ●関連記事ファイルを開く
open($kr_handler,"<$krfile");
flock($kr_handler,1);
	while(<$kr_handler>){
		chomp;
		my($no2,$moto2,$sub2,$domain2,$num2) = split(/<>/);
		if($no2 == $unwork_no && $moto2 eq $unwork_moto){ $change++; next; }
		push(@krline,"$no2<>$moto2<>$sub2<>$domain2<>$num2<>\n");
	}
close($kr_handler);

# 変更点が無かった場合
if(!$change){ &rperror("元ページ内にリンク切れが存在しないか、既に修正済みです。<a href=\"$repair_url\">→元のページへ</a>",$unwork_url); }

# 記事のバックアップを更新
#Mebius::Fileout("",$savefile,$saveline);

# 関連記事ファイルを更新
Mebius::Fileout("Allow-empty","$krfile",@krline);

# 修正履歴を更新
&access_log("Repair-url","元ページ： $repair_url<br>リンク切れＵＲＬ： $unwork_url");

# ロック解除
&unlock($repair_moto);

# リターン
return($line);

}

#-----------------------------------------------------------
# ＵＲＬ修復を実行
#-----------------------------------------------------------
sub repair_auto{

# 宣言
my($type,$data_body,$unwork_url) = @_;
my($changed_num,$change_unwork_url,$deltag1,$deltag2,$notslash_url,$slash);

# http / ttp の処理を調整
$unwork_url =~ s/^http//g;

# 末尾スラッシュの処理
$notslash_url = $unwork_url;
$slash = ($notslash_url =~ s/\/$//g);

# 修正跡に取り消し線をつける場合
if($type =~ /Strike/){ ($deltag1,$deltag2) = ("<del>","</del>"); }

# リンクを修正
$changed_num += ($data_body =~ s/([^=^\"]|^)http\Q$unwork_url\E(#[a-zA-Z0-9]+|)([^a-z0-9_\.\/\?]+|$)/$1${deltag1}ttp$unwork_url${2}${deltag2}${3}/g);


	# スラッシュの処理
	if($slash && !$changed_num){
$changed_num += ($data_body =~ s/([^=^\"]|^)http$notslash_url(#[a-zA-Z0-9]+|)([^a-z0-9_\.\/\?]+|$)/$1${deltag1}ttp$notslash_url${2}${deltag2}${3}/g);
	}

return($data_body,$changed_num);
}


#-----------------------------------------------------------
# レス番の修正
#-----------------------------------------------------------
#sub repair_resnumber_auto{

# 宣言
#my($type,$data_body,$resnumber) = @_;
#my($changed_num);

# 汚染チェック
#$resnumber =~ s/\D//g;
#if($resnumber eq ""){ return(); }

# レス番を修正
#$changed_num += ($data_body =~ s/No\.($resnumber)([^0-9,\-]|$)/&gt;&gt;$1$2/g);

#return($data_body,$changed_num);

#}


#-----------------------------------------------------------
# ＵＲＬ修正に失敗した場合
#-----------------------------------------------------------
sub rperror{

# 局所化
my($error,$redirect_url) = @_;
my($url_type);
our($lockflag,$myadmin_flag);

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }

# ログを記録
main::access_log("Missed-repair-url","元ページ： $main::in{'repair_url'} / リンク切れページ： $redirect_url"); 

# リダイレクト先のＵＲＬをチェック
my($url_type) = Mebius::Referer("",$redirect_url);

# エラーを表示する場合
if($myadmin_flag >= 5 || $url_type !~ /mydomain/){ &error($error); }

# 元ページにリダイレクトして戻す
else{ Mebius::Redirect("",$redirect_url); }

}



1;
