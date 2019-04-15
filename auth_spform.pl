package main;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_spform{

# 局所化
my($file);
our($myadmin_flag);

#汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# 既にスペシャルメンバーの場合
if($main::myaccount{'level2'} >= 1 && !$myadmin_flag){ &error("あなたは既にスペシャル会員です。"); }

# ログインしていない場合
if(!$idcheck){ &error("このページを利用するには、ログインしてください。"); }

# CSS定義
$css_text .= qq(
li{line-height:1.5em;}
.url{width:20em;}
.spimg{}
a:active { color: yellow; }
);

# タイトル決定
$sub_title = "スペシャルメンバー申\請 - $title";
$head_link3 = qq(&gt; スペシャルメンバー申\請);

# 申請処理
if($in{'action'}){ &auth_spform_send_action(); }
elsif($main::in{'type'} eq "checked" && $main::myadmin_flag){ &auth_spmember_apply_file("Renew Be-checked-apply",$main::in{'hash'}); }

# 管理者の表示
if($myadmin_flag){ &auth_spform_admin_view(); }



# ナビ
my $link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">プロフィールへ</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1>スペシャルメンバー申\請</h1>

<h2>説明</h2>

メビウスリングでは、サーバー負荷などの事情により、色々な制限がありますが、<br>
<strong class="red">ホームページやブログなどで、メビウスリングを紹介していただいた方</strong>に限って、<br>
スペシャルメンバーとして、次のボーナスを受けることが出来ます。<br><br>

<h3>ボーナス</h3>

<ul>
<li><a href="$auth_url">ＳＮＳ</a>にログイン中、普通の掲示板で<strong class="red">待ち時間が短縮</strong>されます。</li>
<li>あなたのアカウントで、$friend_tagに登録できる人数が増えます。</li>
<li>あなたから$friend_tag申\請する場合の待ち時間が少なくなります。</li>
</ul>

<br>

あなたのサイトであれば、紹介の方法は問いません。<br>
ブログの１記事として紹介したり、リンク集に入れたりと自由です。<br><br>

<a href="http://www.google.com/support/webmasters/bin/answer.py?answer=66736&amp;query=%E6%9C%89%E6%96%99&topic=&amp;type=">★リンクを貼\る場合は「rel="nofollow"」の属性を使うことをおすすめします</a><br><br>

<strong>紹介の一例</strong>　<span class="red">＊例なので、この通りでなくてもかまいません。</span><br><br>
<a href="http://auraneed.blog98.fc2.com/blog-entry-7.html"><img src="http://mb2.jp/pct/spform1.bmp" alt="紹介の一例" class="spimg"></a><br><br><br>

スペシャル会員希望の方は、次のフォームで、<br>
<strong class="red">メビウスリングを紹介したページのＵＲＬ</strong>をご送信ください。


<form action="$action" method="post">
<input type="text" name="url" value="http://" class="url">
<input type="hidden" name="mode" value="spform">
<input type="hidden" name="action" value="1">

<input type="submit" value="この内容で申\請する" disabled> ※現在、募集停止中です。
</form>

管理者による審査に通ると、スペシャルメンバーとして登録されます。<br><br>

<h2 id="HOSOKU">補足</h2>

<ul>
<li>特典は今後、修正、追加、削除される可能\性があります。</li>
<li>紹介ページが消えてしまったときや、サイトが閉鎖されれてしまった場合は、登録が解除されることがあります。</li>
<li>メビウスリングやＳＮＳでのルール違反により、登録が解除されることがあります。</li>
<li>申\請されたページを探しても、すぐ紹介が見つからない場合、登録されないことがあります。</li>
<li>次のような申\請は、登録されません。「アダルトサイト」「出会い系」「掲示板での紹介」「人のサイトでの紹介」「会員制サイトでの紹介」。</li>
<li>次のような申\請は、登録されない場合があります。「二次創作のあるサイト」「コンテンツ（内容）が少ないサイト」「暴\言、中傷表\現などがあるサイト」「消極的な紹介、悪意のある紹介」。</li>
<li>申\請は何度でも可能\です。</li>
</ul>
$adline
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

#-----------------------------------------------------------
# 申請処理
#-----------------------------------------------------------

sub auth_spform_send_action{

# 局所化
my($line,$file_handler1);

# アクセス制限
main::axscheck("Post-only");

# URLのチェック
$in{'url'} =~ s/ //g;
	if($in{'url'} eq "" || $in{'url'} eq "http://"){ &error("ＵＲＬがカラです。"); }
$http_num = ($in{'url'} =~ s/http:\/\//$&/g);
	if($http_num >= 2){ &error("http:// が2個以上書かれています。"); }
	foreach(@domains){
	if($in{'url'} =~ /^http:\/\/$_/){ &error("メビウスリング内のＵＲＬでは、紹介したことになりません。"); }
	}
	if($in{'url'} !~ /^http/){ &error("http://~ で始まるＵＲＬを入力してください。"); }
	unless($in{'url'} =~ /\.([a-z]+)/){ &error("正しいＵＲＬの形式で入力してください。"); }
	unless($in{'url'} =~ /(\.jp|\.com|\.net)/){ &error("正しいＵＲＬの形式で入力してください。"); }
	if($in{'url'} =~ /(bbs|chat|aura|mb2|youtube|2ch\.net|nicovideo\.jp|twitter\.(com|jp)|\@|\?search)/){ &error("ＵＲＬに $1 を含むページは申\請できません。"); }

# ステータスコードをチェック
my($code) = &get_status($in{'url'});
if($code ne "200"){ &error("$code - 申\請ＵＲＬが見つからない、またはパスワード式のため申\請できません。ＵＲＬを見直してもう一度申\請してください。"); }

# 申請ファイルを更新
main::auth_spmember_apply_file("New-apply Renew",$main::myaccount{'file'},$main::in{'url'});

# メール送信
Mebius::send_email("To-master",undef,"ＳＰ会員申\請が届きました","管理: http://mb2.jp/_auth/spform.html\n\nURL: $in{'url'}");



# HTML
my $print = <<"EOM";

申\請ありがとうございました。<br>
メビウスリングを紹介していただいたのは、次のＵＲＬで良いかご確認ください（ＵＲＬ間違いの場合は、再送信可能\です）。<br><br>

<a href="$in{'url'}">$in{'url'}</a><br><br>

<br>管理者による審査に通過すると、スペシャル会員として登録が完了します。<br>
１週間～１ヶ月ほどお待ちください（<a href="$auth_url">→$titleに戻る</a>）。<br>
$footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}

use strict;

#-----------------------------------------------------------
# 登録ファイル
#-----------------------------------------------------------
sub auth_spmember_apply_file{

# 宣言
my($type) = @_;
my(undef,$account,$new_url) = @_ if($type =~ /New-apply/);
my(undef,$hash) = @_ if($type =~ /Be-checked/);
my($file_handler1,@line,$adline,$i,$action);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

my $file = "${auth_log_directory}splog.cgi";

# ファイルを開く
open($file_handler1,"<",$file);

	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler1,1); }

	while(<$file_handler1>){

		# 分解
		chomp;
		my($account2,$url2,$date2,$hash2,$key2) = split(/<>/,$_);

			# インデックスを取得
			if($type =~ /Get-index/){

				my($red,%account,$anchor_style);

				$i++;

				my($prev) = $i + 1;
				my($next) = $i - 1;

				my($account,$url,$date2) = split(/<>/,$_);
				my $link = qq($main::adir$account/);


				if($i < 500){ (%account) = Mebius::Auth::File("Hash Not-keycheck",$account); }

				if($main::submode2 ne "all" && $i >= 200){ $adline .= qq(<br><a href="spform-all.html">→全て表\示</a><br>); last; }

				if($account{'level2'} >= 1){ $red = qq( class="ok"); }

				my($style1);
					if($key2 =~ /Checked-apply/){ $style1 = qq( style="background:#fdd;"); }
					elsif($i % 2 == 1){ $style1 = qq( style="background-color:#ddd;"); }

				#my($anchor_style);
				#if($submode2 eq $i){ $anchor_style = qq( style="color:#f00;"); }

				$adline .= qq(
				<form action="$action" method="post" class="inline">
				<div id="S$i"$style1>
				$i. <a href="$link"$red$anchor_style>$account{'name'} - $account</a> - <a href="$url"$red$anchor_style>$url</a> $date2
				<input type="hidden" name="mode" value="baseedit">
				<input type="hidden" name="account" value="$account">
				<input type="hidden" name="pplevel2" value="1">
				<input type="hidden" name="ppsurl" value="$url">
				<input type="hidden" name="backurl" value="${main::auth_url}$main::myaccount{'file'}/spform-$next#S$next">
				<input type="submit" value="設定">);

				# フレーム表示
				#if($submode2 eq $i){ 
				#$adline .= qq(
				#<a href="spform-$next#S$next">上</a>
				#<a href="spform-$prev#S$prev">下</a>
				#<iframe src="$url" style="width:100%;height:500px;"></iframe>
				#);
				#}
				#else{
				#$adline .= qq( <a href="spform-$i#S$i">フレーム</a>);
				#}

				$adline .= qq(</form>\n);

				$adline .= qq(<form action="./#S$next" method="post" class="inline">\n);
				$adline .= qq(<input type="hidden" name="mode" value="$main::mode">\n);
				$adline .= qq(<input type="hidden" name="type" value="checked">\n);
				$adline .= qq(<input type="hidden" name="hash" value="$hash2">\n);
				$adline .= qq(<input type="submit" value="確認">\n);
				$adline .= qq(</form>\n);

				$adline .= qq(</div>\n);

				# フレーム表示

			}

			# 新規申請する場合
			if($type =~ /New-apply/){

					if($account2 eq $account && $url2 eq $new_url){
						close($file_handler1);
						&error("このＵＲＬは申\請済みです。");
					}

			}

			# 確認する場合
			if($type =~ /Be-checked/){

					if($hash2 && $hash2 eq $hash){
						$key2 =~ s/(\s)?Checked-apply//g;
						$key2 .= qq( Checked-apply);
					}

			}

			# 更新する場合
			if($type =~ /Renew/){

					if(!$hash2){ $hash2 = Mebius::Crypt::char(); }

				push(@line,"$account2<>$url2<>$date2<>$hash2<>$key2<>\n")

			}
	


	}
close($file_handler1);

	# 新しい行を追加
	if($type =~ /New-apply/){
		my $new_hash = Mebius::Crypt::char();
		unshift(@line,"$account<>$new_url<>$main::date<>$new_hash<>\n");
	}


	# ファイルに書き込む
	if($type =~ /Renew/){
		Mebius::Fileout(undef,$file,@line);
	}

	# インデックス取得用
	if($type =~ /Get-index/){
		return($adline);
	}


}

no strict;

#-----------------------------------------------------------
# 管理者の表示
#-----------------------------------------------------------

sub auth_spform_admin_view{

# 局所化
my($i,$spfile_handler);

$css_text .= qq(
.ok{color:#bbb;}
);

($adline) = &auth_spmember_apply_file("Get-index");



if($adline){ $adline = qq(<h2>申\請一覧（管理者用）</h2>$adline); }

}


1;
