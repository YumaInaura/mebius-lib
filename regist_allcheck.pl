
# 基本宣言
use Mebius::Echeck;
use Mebius::RegistCheck;
use Mebius::Getstatus;
use Mebius::Text;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# 題名のチェック
#-----------------------------------------------------------
sub subject_check{

# 宣言
my($type,$subject,$category,$concept) = @_;
my($check_subject);
my($alert_flag,$error_flag,$long_length,$short_length,$bad_keyword);
our($e_com,$a_com,$delete_url);

# 題名を基本変換
($subject) = &base_change($subject);

	# 改行を即刻禁止
	if($subject =~ /<br>/){ main::error("題名では改行できません。"); }

	# 異常な長さの題名を即刻禁止
	if(length($subject) > 1000){ main::error("題名が長すぎます。"); }

# 題名の長さを取得
($long_length,$short_length) = &get_length("",$subject);

# チェック用に題名をエスケープ
$check_subject = Mebius::escape("Space",$subject);

# URLチェック
if($check_subject =~ m!(ttp|://|\.com|\.jp|\.net)!){ $e_com .= qq(▼題名にＵＲＬは使えません。); }

	# 題名の長さチェック
	if($type !~ /Empty/ && ($check_subject eq "" || $check_subject =~ /^(\x81\x40|\s|<br>)+$/)){ $e_com .= qq(▼題名が空白、または記号だけです。<br>); }
	elsif($long_length > 25){ $e_com .= qq(▼題名が長すぎます。（ 全角 $long_length文字 / 25文字 ）<br>); }
	elsif($type !~ /Empty/ && $short_length < 1){ $e_com .= qq(▼題名が短すぎます。<br>); }

# 創作モードでは題名をチェックしない
#if($type =~ /Sousaku/ && $category ne "diary"){ return($subject); }

	# 題名をチェック（エラー用）
	if($check_subject =~ /(き|キ|気|基)(ち|チ|地)(がい|ガイ|害|外)/){ $error_flag = qq(evil); }
	if($check_subject =~ /(つるぺた)/){ $error_flag = qq(sex); }

	# 題名をチェック（アラート用）
	if($check_subject =~ /(ムカ|むか|イラ|いら)(ツク|つく|ついた)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(イラ|いら|苛|腹)(立つ)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(イライラ|いらいら|苛々|苛苛)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(う|ウ) ( (ざ|ザ)(い|イ|すぎ) | (ぜ|\Qゼ\E)(え|ぇ|エ|ェ) ) /x){ $alert_flag = qq(evil); }
	if($check_subject =~ /キモ(イ|ィ|い|ぃ)|\Qｷﾓｲ\E/x){ $alert_flag = qq(evil); }
	if($check_subject =~ /(UZEEE|うっざ|ウッザ|爆発しろ)/x){ $alert_flag = qq(evil); }
	if($check_subject =~ /(厨|消防([^車]|$)|最悪|(いい)(かげん|加減))|(ふ)?ざけ(る|ん|るん)(な|じゃ)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(五月蝿い|うるさい|糞)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(幼女|エッチ)/){ $alert_flag = qq(sex); }
	if($check_subject =~ /(文通)/){ $alert_flag = qq(private); }
	if($check_subject =~ /(荒らし)/){ $alert_flag = qq(reverse); }
	if($check_subject =~ /(文通|彼氏|彼女)/ && $check_subject =~ /(募集)/){ $alert_flag = qq(deromance); }
	if($check_subject =~ /(愚痴|グチ)/){ $alert_flag = qq(gutty); }
	if($check_subject =~ /(クリック)/){ $error_flag = qq(fuse); $bad_keyword = $1; }

	# エラーフラグがある場合
	if($error_flag eq "fuse"){
		$e_com .= qq(▼題名にこのキーワード ( $bad_keyword ) は使えません。 具体的な題名をつけてください。<br>);
	}

	elsif($error_flag){
		$e_com .= qq(▼この題名は書き込めません。　利用上のマナーにご配慮ください。<br>);
	}

	# フラグがある場合
	elsif($alert_flag eq "evil"){
		$a_com .= qq(▼題名チェック - マナーを欠いた\表\現\がありませんか？　投稿内容には十\分\ご配慮ください。<br>);
	}
	
	# フラグがある場合
	elsif($alert_flag eq "sex"){
		$a_com .= qq(▼題名チェック - 性的な内容や、児童性愛を助長させかねない内容が含まれていませんか？（ネタ、冗談など含む）　利用上のマナーにご配慮ください。<br>);
	}
	# フラグがある場合
	elsif($alert_flag eq "private"){
		$a_com .= qq(▼題名チェック - 個人情報の交換をしようとしていませんか？　個人情報は絶対に扱わないでください。<br>);
	}
	# フラグがある場合
	elsif($alert_flag eq "gutty" && $concept !~ /Sousaku/){
		$a_com .= qq(▼題名チェック - 愚痴は必ずしも禁止ではありませんが、<strong>「うざい」「死ね」</strong>などの\暴\言を書き込まないよう、お願いいたします。<br>);
	}
	
	# フラグがある場合
	elsif($alert_flag eq "reverse" && $concept !~ /Sousaku/){
		$a_com .= qq(▼題名チェック - 荒らし行為へ反応をなさっていませんか？　荒らしには<a href="$delete_url">削除依頼</a>をお願いします。<br>);
	}
	# フラグがある場合
	elsif($alert_flag eq "deromance" && $concept !~ /Sousaku/){
		$a_com .= qq(▼題名チェック - 本サイトでは「恋人募集」「文通相手募集」などの出会い系利用は出来ません。。<br>);
	}


	# エラー/アラートを記録
	if($error_flag){
		 Mebius::Echeck::Record("","Subject","題名： $subject");
	}

	elsif($alert_flag){
		Mebius::Echeck::Record("","Subject","題名： $subject");
		$main::alert_type .= qq( 題名);
	}

# リターン
return($subject,$error_flag,$alert_flag);

}

use strict;

#-----------------------------------------------------------
# 文字数チェック
#-----------------------------------------------------------
sub length_check{

# 宣言
my($check,$name,$max,$mini) = @_;
my $length = int(length($check) / 2);
our($e_com);

	if($max && $length > $max){ $e_com .= qq(▼$nameが長すぎます。（ 現在$length文字 / 最大$max文字 ）<br>); }
	if($mini && $length < $mini){ $e_com .= qq(▼$nameが短すぎます。（ 現在$length文字 / 最小$mini文字 ）<br>); }

	if($mini >= 1 && ($check eq "" || $check =~ /^(\x81\x40|\s|<br>)+$/)){ $e_com .= qq(▼$nameを入力してください。<br>); }

}


#-----------------------------------------------------------
# 本文の文字数計算
#-----------------------------------------------------------
sub get_length{

# 宣言
my($type,$check) = @_;
my($long_length,$short_length,$spacenum,$halfnum,$length1,$length2,$decration_length,$kasegi_length);

# 長い文字数の計算
$long_length = int(length($check) / 2);

	# デコレーション量を判定
	foreach(split(/<br>/,$check)){

		# 局所化
		my($text2) = ($_);
		my($empty_length);

		# URLを消去
		($text2) = Mebius::url({ EraseURL => 1 },$text2);

		# スタンプ部分を消去
		($text2) = Mebius::Stamp::erase_code($text2);

			# ナンバーリンクはエスケープしない 
			if($text2 =~ /^(\s+)?(&gt;|＞)(&gt;|＞)(\d+)/){
				0;
			# 引用部分はエスケープ
			} elsif($text2 =~ /^(\s+)?(&gt;|＞)/){
				next;
			}

			# 他のエスケープ
			if($text2 =~ /本文は全角(\d+)文字以上を書いてください/){ next; }
			if($text2 =~ /本文の文字数が少なすぎます/){ next; }

		$text2 =~ s/(　| )//g;
		$text2 =~ s/((文字|もじ|ｍｊ)(数)?((稼|かせ)ぎ)?){2,}//g;

		$decration_length += ($text2 =~ s/(&apos;|&quot;)/$&/g) * (3.0  - 0.5);	# あとで判定する ; を重複カウントしないように
		$decration_length += ($text2 =~ s/(&#39;|&amp;)/$&/g) * (2.5 - 0.5 );	# あとで判定する ; を重複カウントしないように
		$decration_length += ($text2 =~ s/(&gt;|&lt;)/$&/g) * (2.0 - 0.5);		# あとで判定する ; を重複カウントしないように
		$decration_length += ($text2 =~ s/(\.|,|w|!|\?){2}/$&/g);
		$decration_length += ($text2 =~ s/(★|☆|●|○|▼|▽|▲|△|◆|◇|■|□|♪|◎|＠|О|〇|＊|†|∮|∞|＞|＜)/$&/g);
		$decration_length += ($text2 =~ s/(⌒|≡|＋|＝|〓|━|─|￣|＿|―\|・|…|\Q－\E)/$&/g);

		$decration_length += ($text2 =~ s/(∩|屮|ヽ|≦|≧|φ|ω|∀|∇|Д|｀|´|＼)/$&/g);
		$decration_length += ($text2 =~ s/(，)/$&/g);
		$decration_length += ( ($text2 =~ s/(。|、|ｗ|！|？|～|\Qー\E){2}/$&/g) * 2 );
		$decration_length += ( ($text2 =~ s/(\*|-|\+|_|=|:|;|｡|ﾟ|\/|\(|\)|\^|\~|`)/$&/g) * 0.5 );

		$kasegi_length += ( ($text2 =~ s/(あ|い|う|え|お){5}/$&/g)*5 );


		$short_length += length($text2);

	}


	# 短い方の文字数を計算
	$short_length = int($short_length/2);

	# 長さを差し引く場合
	if($type =~ /Decoration-cut/ && $decration_length){ $short_length -= $decration_length; }
	if($type =~ /Decoration-cut/ && $decration_length){ $short_length -= $kasegi_length; }

	# 調整
	if($short_length <= 0){ $short_length = 0; }

# 整数にする
$short_length = int $short_length;
$long_length = int $long_length;

# リターン
return($long_length,$short_length,$decration_length);

}



#-------------------------------------------------
# 外部のＵＲＬ，アドレスチェック
#-------------------------------------------------
sub url_check{

my $regist = new Mebius::Regist;
my $error = $regist->url_check($_[1],$_[0]);

	if($error){ 
		shift_jis($error);
		$main::e_com .= $error;
	}

}


no strict;

#-----------------------------------------------------------
# 基本変換
#-----------------------------------------------------------
sub base_change{

# 宣言
my($check,$mode) = @_;
my($return_check,$hit,$comment_split);
our($realmoto,$concept);

# ●１行ずつに対する処理

	# 文章を改行で展開
	foreach $comment_split (split(/<br>/,$check,-1)){

		# 記号のみの行はエスケープ
		if($comment_split =~ /^(\.|,)$/){ next; }

		# 連続した半角スペースを削除
		$comment_split =~ s/\s+/ /g;

			# 連続した全角スペースを削除
			if($main::bbs{'concept'} !~ /Sousaku-mode/){
				$comment_split =~ s/((　|\s){8,})/　　　　　　　　/g;
			}

			# 携帯版から投稿する場合
			if($main::kflag){
				$comment_split =~ s/^(　|\s){2,}/　　/g;
				$comment_split =~ s/(　|\s){2,}/　　/g;
			}

		# 全角記号の羅列を短縮
		if($concept !~ /Sousaku/){
			$comment_split =~ s/(～){15,}/～～～～～～～～～～～～～～～/g;
			$comment_split =~ s/(あ){15,}/あああああああああああああああ/g;
			$comment_split =~ s/(い){15,}/いいいいいいいいいいいいいいい/g;
			$comment_split =~ s/(う){15,}/ううううううううううううううう/g;
			$comment_split =~ s/(え){15,}/えええええええええええええええ/g;
			$comment_split =~ s/(お){15,}/おおおおおおおおおおおおおおお/g;
			$comment_split =~ s/(！){15,}/！！！！！！！！！！！！！！！/g;
			$comment_split =~ s/(・){15,}/・・・・・・・・・・・・・・・/g;
			$comment_split =~ s/(\Qー\E){15,}/ーーーーーーーーーーーーーーー/g;
		}

		# 過剰なwｗを削除
		$comment_split =~ s/(ｗ|w|v|ｖ)((ｗ|w|v|ｖ){5,})/wwwww/g;

		# ＵＲＬを基本整形
		$comment_split =~ s/([a-z0-9]+),(jp|net|com)/$1.$2/g;
		$comment_split =~ s/(^|\/|[^h])ttp:\/\/([a-z0-9\.]+?)\//$1 http:\/\/$2\//g;
		$comment_split =~ s/mb2(\.|,)jp\/(-|\.)([0-9a-z]+?)\//mb2\.jp\/_$3\//g;
		$comment_split =~ s/(\.ntml|\.htm([^l<]|$))/\.html/g;
		$comment_split =~ s/\.html([^-#])/\.html $1/g;
		$comment_split =~ s/http:\/\// http:\/\//g;
		$comment_split =~ s/&quot;&gt;/ &quot;&gt;/g;
			if(!$main::secret_mode){ $comment_split =~ s/\/_sc([a-z0-9]{2,10})\//\/_test\//g; }

		# 携帯版をデスクトップ版に
		#$comment_split =~ s/k([0-9]+)(|_data|_memo)\.html/$1$2\.html/g;
		#$comment_split =~ s/km0\.html//g;
		#$comment_split =~ s/mode=k(view|find)/mode=$1/g;
		#$comment_split =~ s/${auth_url}([a-z0-9]+)\/iview($|[^0-9a-zA-Z\-])/${auth_url}$1\/ $2/g;

		# 検索向けAdsense のＵＲＬ
		#$comment_split =~ s/https?:\/\/www\.google\.co\.jp\/(custom|cse)\?([a-zA-Z0-9%&;=_\-\.]+)&amp;q=([a-zA-Z0-9%_ \+\-]+)&amp;([a-zA-Z0-9%&;=\-]+)&amp;cx=%21([a-zA-Z0-9%&;=\-]+)(#[.]+)?/http:\/\/www\.google\.co\.jp\/search?hl=ja&amp;q=$3/g;
		if(!Mebius::alocal_judge()){	
			$comment_split =~ s/https?:\/\/www\.google\.co\.jp\/(custom|cse)\?([a-zA-Z0-9%&;=_\-\.]+)&amp;q=([a-zA-Z0-9%_ \+\-]+)&amp;([a-zA-Z0-9%&;=\-]+)(#[.]+)?/http:\/\/www\.google\.co\.jp\/search?q=$3&amp;sitesearch=mb2\.jp&amp;ie=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp/g;
		}

		# 特殊文字を変換
		$comment_split =~ s/&amp;([#a-zA-Z0-9]+);/□/g;

			# 削除依頼時のレス番を整形 ( 1 )
			if($realmoto eq "delete"){
				$comment_split =~ s/#([A-Za-z])([a-zA-Z0-9\-_]+)//g;
				$comment_split =~ s/(NO\.|NO．)/No./g;
			}

		# レス番の整形 ( 2 )
		# №
		$comment_split =~ s/(No\.|No．|Ｎｏ．|ＮＯ．|&gt;&gt;|＞＞|#)([0-9０１２３４５６７８９]+)((,|\-|\~|\.|、|，|。|．|・|～|(\Q－\E)|(\Qー\E))([0-9,\.０１２３４５６７８９、，。．・\-～(\Qー\E)(\Q－\E)]+)|;||$)/&fix_resnumber($1,$2,$3,$4)/eg;
		#$comment_split =~ s/No\.([0-9,\-]+)/&fix_redun_resnumber($1)/eg;
		$comment_split =~ s/No\.([0-9,\-]+)/ No\.$1 /g;

#>>445-565,6765


		# 行末の連続空白を削除
		$comment_split =~ s/(　)+$//g;
		$comment_split =~ s/\s$//g;

			# 太字タグ変換
			#if($main::cgold >= 1 && ($comment_split =~ s/&apos;&apos;&apos;/$&/g) >= 2){
			#$comment_split =~ s|&apos;&apos;&apos;|<strong>|;
			#$comment_split =~ s|&apos;&apos;&apos;|</strong>|;
			#}

			## 取り消しタグ変換
			#if($main::cgold >= 1 && ($comment_split =~ s/===/$&/g) >= 2){
			#$comment_split =~ s|===|<strike>|;
			#$comment_split =~ s|===|</strike>|;
			#}

		# 空白のみの行は削除
		if($comment_split =~ /^([ 　]+)$/){ $comment_split = qq(); }

		# ヒットカウンタ
		$hit++;

			# ２ラウンド以降は改行を追加
			if($hit >= 2){ $return_check .= qq(<br>); }

		# リターン文を追加
		$return_check .= qq($comment_split);

	}


# ●文全体に対する処理

	# 文頭/文末の改行を削除
	if($main::kflag){
			if($main::bbs{'concept'} =~ /Sousaku-mode/){ $return_check =~ s/(<br>){5,}/<br><br><br><br><br>/g; }
			else{ $return_check =~ s/(<br>){3,}/<br><br><br>/g; }
	}

	# 連続改行＆空白を消去
	if($main::bbs{'concept'} =~ /Sousaku-mode/){
		$return_check =~ s/((<br>){20,})/<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>/g;
	}
	else{
		$return_check =~ s/(　){20,}/<br>/g;	
			# 行頭の改行
			if($main::kflag){
				$return_check =~ s/^(<br>)+//g;
			}
			else{
				$return_check =~ s/^(<br>){2,}/<br><br>/g;
			}

		$return_check =~ s/((<br>){10,})/<br><br><br><br><br><br><br><br><br><br>/g;

		$return_check =~ s/((<br>)+)$//g;
	}



# リターン
return($return_check);

}

#-----------------------------------------------------------
# レス番の整形
#-----------------------------------------------------------
sub fix_resnumber{

# 局所化
my($line,$plus,$return);
my($F1,$F2,$F3,$F4) = @_;

$return = "$F1$F2$F3";

# 特定の処理
if($F4 eq ";"){ return(); }
if(!$in{'k'} && $device_type ne "mobile" && ($F1 eq "#") ){ return("$return"); }
#if($F1 eq "レス番："){ $plus = $F1; }

# 大文字を小文字に
($F2) = &bigsmall_number($F2);
($F3) = &bigsmall_number($F3);
$F3 =~ s/(～|\~|(\Qー\E)|(\Q－\E))/\-/g;

# カンマ変換
$F3 =~ s/(\.|、|，|。|．|・)/,/g;
$F4 =~ s/(\.|、|，|。|．|・)/,/g;

# 英数字以外が混じっている場合
if($F2 ne "" && $F2 !~ /[0-9]/){ return($return); }
if($F3 ne "" && $F3 !~ /[0-9\-,]/){ return($return); }

# ０は最初につかない
$F2 =~ s/^([0]+)([0-9]+?)/$2/g;
$F3 =~ s/([^0-9])([0]+)([0-9]+?)/$1$3/g;

# 行を定義
$line = qq(${plus}No\.$F2$F3);

# 最終整形
$line =~ s/\-,/\-/g;
$line =~ s/,\-/,/g;
$line =~ s/\-{2,5}/\-/g;
$line =~ s/,{2,5}/,/g;
$line =~ s/\-$//g;
$line =~ s/\,$//g;

# フラグ
$fix_resnumber_flag = 1;

# リターン
return($line);

}

#-----------------------------------------------------------
# ２個以上の範囲指定を整形
#-----------------------------------------------------------
#sub fix_redun_resnumber{

# 局所化
#my($line,$hit1,$hit2,$buf,$i);
#my($F1) = @_;

# 判定
#($hit1) += ($F1 =~ s/\-/$&/g);
#($hit2) += ($F1 =~ s/\,/$&/g);

# リターン
#if(!$hit1 || !$hit2){ return("No\.$F1"); }

# 展開
#foreach(split(/\,/,$F1)){
#$i++;
#if($i >= 2){ $buf .= qq(\,); }
#$_ =~ s/^([0-9]+)\-([0-9]+)$/&fix_redun_resnumber2($1,$2)/e;
#$buf .= $_;
#}

# 整形用サブルーチン
#sub fix_redun_resnumber2{
#my($F1,$F2) = @_;
#my($i,$buf,$round);
#if($F1 > $F2){ ($F1,$F2) = ($F2,$F1); }
#$i = $F1;
#for($F1 .. $F2){
#$round++;
#if($i >= 100){ last; }
#if($round >= 2){ $buf .= qq(,); }
#$buf .= qq($i);
#$i++;
#}
#return($buf);
#}

# 行を定義
#$line = qq(No\.$buf);

# リターン
#return($line);
#}

#-----------------------------------------------------------
# 大文字数字を小文字数字に
#-----------------------------------------------------------
sub bigsmall_number{

my($check) = @_;

$check =~ s/１/1/g;
$check =~ s/２/2/g;
$check =~ s/３/3/g;
$check =~ s/４/4/g;
$check =~ s/５/5/g;
$check =~ s/６/6/g;
$check =~ s/７/7/g;
$check =~ s/８/8/g;
$check =~ s/９/9/g;
$check =~ s/０/0/g;

return($check);

}

#-----------------------------------------------------------
# 次の待ち時間計算 ( 主に SNS ）
#-----------------------------------------------------------
sub wait_check{

my($check_length,$pcbonus) = @_;
my($waitmin,$toppa);


# ＰＣ待ち時間
@waitlist = (
'150=0.5',
'125=0.75',
'100=1.0',
'75=1.5',
'50=2.5',
'40=3.0',
'30=3.5',
'20=4.0',
'10=4.5',
'0=5.0'
);

# 携帯待ち時間
@kwaitlist = (
'150=0.5',
'125=0.75',
'100=1.0',
'75=1.25',
'50=1.5',
'40=1.75',
'30=2.25',
'20=2.75',
'10=3.25',
'0=5.0'
);



# 待ち時間を計算（携帯）
if($k_access){
foreach(@kwaitlist){
my($length,$next) = split(/=/,$_);
# 待ち時間決定
if($check_length >= $length){ $waitmin = $next; $toppa = $length; last; }
}
}

# 待ち時間を計算（ＰＣ）
else{
foreach(@waitlist){
my($length,$next,$bord) = split(/=/,$_);
# 待ち時間決定
if($check_length >= $length){ $waitmin = $next; $toppa = $length; last; }
}
# 個別ボーナス
if($pcbonus){ $waitmin *= $pcbonus; }
}


# 待ち秒数を計算
$waitsec = int($waitmin*60);

# スペシャル会員ボーナス
if($idcheck && $main::myaccount{'level2'} >= 1){ $waitsec -= 20; }

# 下限調整
if($waitsec < 30){ $waitsec = 30; }

# 次の待ち時間の秒分を計算
my $nextmin = int($waitmin);
my $nextsec = ($waitsec) - ($nextmin*60);


return($waitsec,$toppa,$nextmin,$nextsec);

}

use strict;

#-------------------------------------------------
#  デコレーションの判定 - strict
#-------------------------------------------------
sub deco_check{

# 宣言
my($type,$check,$category,$concept) = @_;
my($check2,$check_pure,$comment,$raretsu_flag,$ndeconum,$deconum,$error_flag);
my($error_decoper,$decoper,$adv_copynum,$comment_length,$datecopy_num,$datecopy_max,$copy_flag,$mechakucha_num,$mechakucha_max,$comment_split,$check_flag);
my($prev_text,$prev_sametext_flag,%dup_text,$over_length_flag);
our($concept,$short_length,$long_length,$decoper,$e_com,$guide_url,$category,$echeck_oneline,$alocal_mode);

# フック
$check2 = $check_pure = $comment = $check;

# 判定のために空白改行、ＵＲＬを除外
$check =~ s/(http\:\/\/[\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\#\%\*]+)//g;
($check) = Mebius::delete_all_space($check);

# 本文の文字数を計算
$comment_length = int (length($check) / 2);

	# あいうえおの羅列
	if($check =~ /^
		((あ)+|(い)+|(う)+|(え)+|(お)+)
	$/x){
		$e_com .= qq(▼ひらがなを羅列しないでください。);
		$error_flag = qq(あいうえお);
	}

	# 文字数が少ない場合はリターンする
	if(!$error_flag && $comment_length <= 75) { return(0); } 

#$ndeconum += ($check =~ s/(＿|━|─)/$&/g);
#$ndeconum += int( ($check =~ s/(\.)/$&/g) *0.5 );

# １行あたりの最大文字数（全角）
my $maxlength_per_line = 1000;

	# 文字数に応じて、最大パーセントを設定 (文字数が多い時の方が厳しく）
	$error_decoper = 50;
		if($comment_length >= 100){	$error_decoper = 50; }
		if($comment_length >= 200){	$error_decoper = 40; }
		if($comment_length >= 400){	$error_decoper = 35; }
		if($concept =~ /(Allow-decoration)/){ $error_decoper = 80; }
		elsif($type =~ /Sousaku/){ $error_decoper = 50; }

	# 現在のパーセント取得
	($long_length,$short_length,$deconum) = &get_length("",$check);
	if($short_length){ $decoper = int($deconum / $short_length * 100); }

	# デコレーション制限
	if($decoper > $error_decoper){
		$e_com .= qq(▼<a href="${guide_url}%A5%C7%A5%B3%A5%EC%A1%BC%A5%B7%A5%E7%A5%F3">文章全体に対して記号、デコレーション、区切り線などが多すぎます。（ 現在${decoper}％ / 最大${error_decoper}％ ）</a><br>　記号、デコレーション、区切り線などを減らしてください。<br>);
		$error_flag = qq(デコレーション);
	}




	# ●文字羅列を禁止（メチャクチャな文章）

		# １行ずつ展開
		foreach $comment_split (split(/<br>/,$check2)){

			# 局所化
			my($buf1,$buf2,$max_buf1,$max_buf2);

			# 設定
			$max_buf1 = 20;
			$max_buf2 = 50;

				# URLを除外
				($comment_split) = Mebius::url({ EraseURL => 1 },$comment_split);

				# 除外
				$comment_split =~ s/（(.{1,10})）//g;
				$comment_split =~ s/\((.{1,10})\)//g;

				# １行が長すぎる場合
				if(length($comment_split) >= 2*$maxlength_per_line){
					$over_length_flag = int(length($comment_split)/2);
				}

				# ●文字の羅列を禁止
				if($type !~ /Sousaku/){

						# ▼ありがちな羅列チェック
						if($comment_split =~ /
							(あ|い|う|え|お|ぁ|ぃ|ぅ|ぇ|ぉ|ア|イ|ウ|エ|オ|ァ|ィ|ゥ|ェ|ォ|！|？|・|～|\Qー\E)
						{30,}
						/x){ $raretsu_flag = qq($&); }

						# ▼ひらがな/カタカナ羅列チェック
						if($comment_split =~ /
							([
							あいうえおかきくけこさしすせとたちつてとなにぬねのはひふへほまみむめもやゆよわをん
							ぁぃぅぇぉ
							]){100,}/x)
						{ $raretsu_flag = qq($&); }
							#アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨワヲン
							#ァィゥェォ
				}


				# 全行と同じ文章？
				if(length($comment_split) >= 2*10 && $comment_split !~ /^(━|─)+$/){
					$dup_text{$comment_split}++;
				}
				if(length($comment_split) >= 2*5){
						if($prev_text eq $comment_split){ $prev_sametext_flag++; }
					$prev_text = $comment_split;
				}

				# 普通の日本語はエスケープ
				if(($comment_split =~ s/(、|。|「|」)/$&/g) >= 5){ $max_buf1 *= 3; } 

			# 一段目チェック
			$buf1 += ($comment_split =~ s/(ｑ|ｗ[^ｗ]|ｅ|ｒ|ｔ|ｙ|ｕ|ｉ|ｏ|ｐ|ａ|ｓ|ｄ|ｆ|ｇ|ｈ|ｊ|ｋ|ｌ|ｚ|ｘ|ｃ|ｖ|ｂ|ｎ|ｍ|＠)/$&/xg);
				if(($comment_split =~ s/(ｅ|ｕ|ｉ|ｏ|ａ)/$&/g) >= 5){ $buf1 = 0; }


			# 二段目チェック
			$buf2 += ($comment_split =~ s/(１|２|３|４|５|６|７|８|９|０|ヴ|】|；)/$&/xg);

				# 三段目チェック
				if($comment_split =~ /([a-zA-Z0-9]{50,})/){ $mechakucha_num = "?"; $mechakucha_max = 50; last; }

				# 片方が一定数以上ある場合は、１に２を合算する
				if($buf1 >= 10 || $buf2 >= 25){ $buf1 += $buf2; }

				# 超過判定
				if($buf1 >= $max_buf1){ $mechakucha_num = $buf1; $mechakucha_max = $max_buf1; $check_flag = $comment_split; last; }
				if($buf2 >= $max_buf2){ $mechakucha_num = $buf2; $mechakucha_max = $max_buf2; $check_flag = $comment_split; last; }


				
		}

			# 各業の文章を展開
			my $max_duplication_line = 5;
			my($dupulication_line);
			foreach(keys %dup_text){
				if($dup_text{$_} >= $max_duplication_line){
					if($dupulication_line){ $dupulication_line .= qq(　該当行：$_　( $dup_text{$_} 行 / $max_duplication_line 行 ) <br$main::xclose>); }
					else{ $dupulication_line = qq(　該当行：$_　( $dup_text{$_} 行 / $max_duplication_line 行 ) <br$main::xclose>); }
				}
			}
			if($dupulication_line && !$error_flag && $type !~ /Sousaku/){
				#$e_com .= qq(▼まったく同じ行を、いくつも書き込むことは出来ません。<br>$dupulication_line);
				#$error_flag = qq(同じ文章行-typeB);
			}


			# ▼文字の羅列判定
			if($raretsu_flag){
				$e_com .= qq(▼<a href="${guide_url}%CA%B8%BB%FA%BF%F4%B2%D4%A4%AE">記号や文字の連続が多すぎます。</a> ( $raretsu_flag )<br>　「ーーーー」「～～～～」「！！！！」「・・・・」「あいうえお」など連続を減らしてください。<br>);
				$error_flag = qq(文字羅列 - $raretsu_flag);
			}

			# 重複行の判定
			my $max_dupulicate_line_num = 5;
			if($prev_sametext_flag >= $max_dupulicate_line_num && !$error_flag && $type !~ /Sousaku/){
				$e_com .= qq(▼文章全体で同じ行が多すぎます。 ( $prev_sametext_flag行 / ${max_dupulicate_line_num}行 )<br>);
				$error_flag = qq(同じ文章行-typeA);
			}

			# 滅茶苦茶な文章
			if($mechakucha_num && !$error_flag && $type !~ /Sousaku/){
				$e_com .= qq(▼文字を滅茶苦茶に打たないでください。荒らしは削除/投稿制限をさせていただく場合があります。 ( $mechakucha_num / $mechakucha_max )<br>　該当行： <em>$check_flag</em><br>);
				$error_flag = qq(滅茶苦茶($mechakucha_num/$mechakucha_max)-$check_flag);
			}


			# 長すぎる１行
			if($over_length_flag && !$error_flag && $type !~ /Sousaku/){
				$e_com .= qq(▼１行が長すぎます。適度に段落分けしてください。( $over_length_flag 文字 / $maxlength_per_line 文字 )<br>);
				$error_flag = qq(長すぎる１行($mechakucha_num/$mechakucha_max)-$check_flag);
			}

	# メビアドの大量コピー禁止
	if(index($check_pure,"ダメージ") >= 0 && !$error_flag){
		$adv_copynum = ($check_pure =~ s|HP ([0-9,(兆)(億)(万)]+) / ([0-9,(兆)(億)(万)]+)|$&|g);
		if($adv_copynum >= 4){
			$e_com .= qq(▼メビアド戦闘結果の大量コピーや、転載のみ投稿はご遠慮ください。必要な部分のみを抜粋し、コメントや感想を書いてください。( $adv_copynum\pt / 5pt )<br>);
			$error_flag = qq(メビアド);

		}
	}


# 掲示板からのコピーを禁止
$datecopy_num += ($check2 =~ s|([0-9]{4})/([0-9]{2})/([0-9]{2}) ([0-9]{2}):([0-9]{2})|$&|g);
$datecopy_num += ($check2 =~ s/(\d{1,4})(\s|：)(.+?)：(\d{4})\/(\d{2})\/(\d{2})\((月|火|水|木|金|土|日)\)\s(\d{2}):(\d{2}):(\d{2})(:\d{2})?/$&/g);
$datecopy_num += ($check2 =~ s/--------------------------------------------------------/$&/g);

#if($check2 =~ /--------------------------------------------------------/){ $datecopy_max = 1; }
$datecopy_max = 5;
if($datecopy_num >= $datecopy_max){ $copy_flag = 1; }
#if(($check2 =~ s/--------------------------------------------------------/$&/g) >= 3){ $copy_flag = 1; $datecopy_num = 1; }

	if($copy_flag && !$error_flag){
		$e_com .= qq(▼掲示板等からの丸ごとコピー、大量コピーはご遠慮ください。( $datecopy_num \pt / $datecopy_max pt )<br>);
		$error_flag = qq(コピー);
	}

	# Echeckを記録
	if($error_flag){
		Mebius::Echeck::Record("","Kasegi","$comment");
		Mebius::Echeck::Record("","All-error","$comment");
	}

# Echeck記録用
if($check_flag){ $echeck_oneline = $check_flag; }

# リターン
return($error_flag,$deconum,$decoper,$error_decoper);

}

#-------------------------------------------------
#  スペース制限 - strict
#-------------------------------------------------
sub space_check{

my($type,$check,$category,$concept) = @_;
my($none,$comment) = @_;
my($aaflag1,$aaflag_last,$aanum,$spacenum,$allspacenum,$halfnum,$error_flag);
my($spaceper,$error_spaceper,$space_com_leng,$spaceover_num,$spaceover_num2,$max_spaceover,$check_flag,$br_num,$all_text_length);
my($basic_init) = Mebius::basic_init();
our($e_com);

	# 文字数が少ない場合はリターン
	if(length($check) < 30*2){ return; }

	# ＡＡ判定（第一段）
	#if($check =~ /(￣|┃)/){ $aaflag1 = 1; }
	if($check =~ /(´|・|ﾟ)(∀|Д|ω|_ゝ|д)(｀|・|ﾟ|`|T)/ && $check =~ /(∧|∩|Ｕ|＿＿)/){ $aaflag_last = 1; }
	if($check =~ /(●([ 　]{3,})●|(コピペ|\Qコピー\E)すると)/){ $aaflag_last = 1; }
	if($check =~ /(AA|ＡＡ|\Qアスキー\E)/){ $aaflag_last = 1; }

	# ＡＡ判定（第二段）
	#if($aaflag1){
	#	$aanum += ($check =~ s/(コピペ)/$&/g);
		#if(($check =~ s/(::|;;|\Q|\E|\Ql\E|\Q｜\E|\Q│\E)/$&/g) >= 20){ $aaflag_last = 1; }
	#	if($aanum >= 5){ $aaflag_last = 1; }
	#	if($check =~ /∧(＿)?∧/){ $aaflag_last = 1; }
	#}

	# ●本文を１行ずつチェックしてＡＡ判定
	foreach my $comment_split (split(/<br>/,$check)){

		# 局所化
		my($text_length,$space_length);
		$text_length = length($comment_split) / 2;

			# この行にスペースがある場合だけ、チェック（記号のみの行をチェックしない）
			if(($comment_split =~ s/(　|＿＿|∧|∩|Ｕ|\s)/$&/g) >= 2){

				# AA文字を判定
				$space_length += ($comment_split =~ s/(　|∧|⊃|彡|人|Ｙ|┃|━|┏|┓|┛|┗|＿|￣|／|）|（|\Q│\E|\Q｜\E|\Q||\E|ii|::|;;|,,)/$&/g);
				$space_length += int(($comment_split =~ s/(\s|\Q|\E)/$&/g)) / 2;
				# 注意 …【\Ql\E】 は文字コードの問題で誤判定が起きるため使わない

				# １行に占める”ＡＡ文字”の割合を計算、○○％以上であればＡＡ判定値を増やす
				if($text_length && $space_length){
					if($text_length >= 5 && ($space_length / $text_length) * 100 >= 70){
						$spaceover_num++;
						$check_flag = join (" / " , $check_flag , $comment_split , "$space_length / $text_length");
					}
				}
			}
	}


	# 空白行のチェック
	if($aaflag_last){ $max_spaceover = 3; } else { $max_spaceover = 6; }
	if($spaceover_num >= $max_spaceover){
			$e_com .= qq(▼空白行、記号行が多すぎます。ＡＡや図を削除してください。$spaceover_num / $max_spaceover<br>);
			$e_com .= qq(　該当行：$check_flag<br>);
			Mebius::Echeck::Record("","Kasegi","$comment");
			Mebius::Echeck::Record("","All-error","$comment");
		$error_flag .= qq(空白行超過($spaceover_num/$max_spaceover));
	}

	# 最大パーセントの設定
	if($aaflag_last){ $error_spaceper = 15; } else { $error_spaceper = 80; }
	$error_spaceper = int($error_spaceper) + 1;

# 現在パーセントの取得
$allspacenum += ($check =~ s/(　|￣)/$&/g);
$allspacenum += ($check =~ s/ /$&/g) / 2;
if(length($check)*2) { $spaceper = int(($allspacenum / (length($check)*2)) * 100); }

	# スペース値が100%以上の場合、表示値修正
	if($spaceper > 100){ $spaceper = 100; }

	# ▼スペース制限
	if($spaceper > $error_spaceper) {
			if($aaflag_last){ $e_com .= qq(▼AA\(アスキーアート\)は禁止です。<br>); }
		$e_com .= qq(▼<a href="$basic_init->{'guide_url'}%A5%B9%A5%DA%A1%BC%A5%B9%C0%A9%B8%C2">文章量に対して、スペース（空白部分）が多すぎます。	（ 現在${spaceper}％ / 最大${error_spaceper}％ ）</a><br>
		　「全角スペース」「半角スペース」の量を減らしてください。<br>
		　日本語として、スペースなしでも書ける文章を推奨します。<br>);
		$error_flag = qq(パーセンテージ超過);
		Mebius::Echeck::Record("","Kasegi","$comment");
		Mebius::Echeck::Record("","All-error","$comment");
	}

	# ▼ハーフ記録
	elsif($spaceper > $error_spaceper / 2){
		#Mebius::Echeck::Record("","SPACE-HIDDEN","$comment");
	}



	# ●改行割合の判定
	my $per_br_num = 2; # 全角何文字あたり、１個の改行を許すか
	my $max_br_num = int($all_text_length / $per_br_num);

	# ▼本文を展開
	foreach my $comment_split (split(/<br>/,$check,-1)){
		$br_num++;
		$comment_split =~ s/( |　)//g;
		$all_text_length += length($comment_split) / 2;
	}

	# ▼改行が一定数以上ある時にだけ判定
	if($br_num >= 5){
		my $max_br_num = int($all_text_length / 1);
			if($br_num > $max_br_num){
				$e_com .= qq(▼テキスト量に対して、改行が多すぎます。( 現在${br_num}個 / 最大${max_br_num}個 )<br>);
			}
	}


	# チェック結果としてAA判定を返す
	if($aaflag_last && $error_flag){ $error_flag .= qq( - AA判定); }

# リターン
return($error_flag,$spaceper,$error_spaceper);

}



no strict;


#-----------------------------------------------------------
# メールアドレスのチェック
#-----------------------------------------------------------
sub address_check{

# 宣言
my($mailto) = @_;
$mailto =~ s/( |　)//g;

if($mailto eq "") { &error("メールアドレスを入力してください。"); }
if(length($mailto) > 256) { &error("メールアドレスが長すぎます。"); }
if($mailto =~ /[^0-9a-zA-Z_\-\.\@]/) { &error("メールアドレスの書式が間違っています。"); }
if($mailto && $mailto !~ /^[\w\.\-]+\@[\w\.\-]+\.[a-zA-Z]{2,6}$/) { &error("メールアドレスの書式が間違っています。"); }

$mailto;

}

#-----------------------------------------------------------
# 全てのチェック
#-----------------------------------------------------------
sub all_check{

my($type,$check,$name) = @_;

$type .= qq( Sjis-to-utf8);

# オーバーフローチェック
Mebius::Regist::OverFlowCheck(undef,$check);

($check) = base_change($check);
Mebius::Regist::private_check($type,$check);
(undef,$deconum) = Mebius::Regist::ChainCheck($type,$check);
url_check($type,$check);
Mebius::Regist::sex_check($type,$check);
Mebius::Regist::EvilCheck($type,$check);
deco_check($type,$check);
space_check($type,$check);
our($bglength,$smlength) = get_length($type,$check,$deconum);

if($name){ ($name) = shift_jis(Mebius::Regist::name_check($name)); }

$e_error = $e_access . $e_sub . $e_com;

	if($type =~ /Error-view/){
		main::error_view();
	}

return($check,$name);

}


#-----------------------------------------------------------
# 注意投稿を記録
#-----------------------------------------------------------
sub rcevil{

# 局所化
my($typename,$comment,$handle,$url,$sub) = @_;
my($line,$i,$flag,@keywords,$keyword);
our($echeck_oneline,$secret_mode,$category,%in);

# リターン
if($secret_mode || $main::bbs{'concept'} =~ /Sousaku-mode/|| $category eq "narikiri" || $category eq "mebi"){ return; }

# 監視キーワード
@keywords = ('メアド','電話','手紙','文通','住所','℡','メール','じぇーぴー','ジェーピー','死ね','tel','ドット','どっと','ウザい','うざい','セックス'
		,'本名');

	# キーワードを検索
	foreach $keyword (@keywords){
		if(index($comment,$keyword ) >= 0){ $flag = 1; }
	}

# アラートを突破した場合は無条件に記録
if($in{'break_alert'}){ $flag = 1; }

if(!$flag){ return; }

$line .= qq(1<>$typename<>$title<>$url<>$sub<>$handle<>$comment<>$i_resnumber<>$time<>$date<>$category<><>$echeck_oneline<>\n);

# ファイルを開く
open(IN,"<${int_dir}_sinnchaku/rcevil.log");
	while(<IN>){
		$i++;
		if($i < 500){ $line .= $_; }
	}
close(IN);

# ファイルを書き出す
Mebius::Fileout("","${int_dir}_sinnchaku/rcevil.log",$line);

}

#-----------------------------------------------------------
# 存在しないレス番表記を自動リンクしないように
#-----------------------------------------------------------
#sub checkres_number{

#my($check,$res) = @_;

#$check =~ s/No\.([0-9,\-]+)/&do_checkres_number($1,$res)/eg;

#return($check);

#sub do_checkres_number{

#my($check,$res) = @_;
#my($flag);
#my($res_start,$res_end) = ($check,$check);

#if($check =~ /-/){ ($res_start,$res_end) = split(/-/,$check); }

#if($check =~ /,/){
#foreach(split(/,/,$check)){
#if($_ > $res_end){ $res_end = $_; }
#if($_ < $res_start){ $res_start = $_; }
#if($_ eq ""){ $flag = 1; }
#}
#}

#if($res_end > $res || $flag){ return("&gt;&gt;$check") }
#else{ return("No.$check"); }
#}

#}


#-----------------------------------------------------------
# 投稿履歴から重複投稿を禁止
#-----------------------------------------------------------
sub regist_double_check{

# 宣言
my($type,$comment) = @_;
my($flag,$thread_link);
my($init_directory) = Mebius::BaseInitDirectory();
my $debug = new Mebius::Debug;
require "${init_directory}part_newlist.pl";
our($e_com);

	# 回避
	if($debug->escape_error()){ return(); }
	if($comment eq ""){ return; }

# サイト全体の最新レスから、重複チェック
($flag,$thread_link) = Mebius::Newlist::threadres("RES Buffer Duplication-check",$comment);
	if(!$flag){ ($flag,$thread_link) = Mebius::Newlist::threadres("THREAD Duplication-check",$comment); }

	if($flag) {
		$e_com .= qq(▼二重投稿ではありませんか？　 元の記事 ( $thread_link ) を確認してみてください。[B]<br>);
		if($main::myadmin_flag >= 5){ $e_com .= qq(チェック： $flag<br>); }
		$doublechecked_flag = 1;
	}

return($flag);

}

#-----------------------------------------------------------
# バッドキーワードをチェック
#-----------------------------------------------------------
sub badword_check{

# 局所化
my($check) = @_;
my($flag);

# キーワード判定
#if($check =~ /(精子|まんこ|マンコ|マ●コ|マ〇コ|乳首|クチュ|全裸|おっぱい|オッパイ|ちんこ|うんこ|ウンコ|オナニ)/){ $flag = 1; }
#if($check =~ /(厨房|厨二|厨２|DQN|ＤＱＮ)/){ }
#if($check =~ /(クソ|カス)/){ }
#if($check =~ /(幼女)/){ }

# エラー
if($flag){
$e_com .= qq(▼このキーワードは登録できません。<br>);
}

}

use strict;

#-----------------------------------------------------------
# エラー画面を表示する
#-----------------------------------------------------------
sub error_view{

# 宣言
my($type,$rootin) = @_;
my(undef,undef,$action) = @_ if($type =~ /View-break-button/);

my($error,$break_alert_checked,$edit_alert_checked,$submit_button);
our($a_com,$e_access,$e_sub,$e_com,%in,$break_alert_input,$guide_url);

# エラーをまとめる
$e_com = $e_access . $e_sub . $e_com;

	# アラートをエラーに変える場合
	if(($type =~ /AERROR/ && $a_com && (!$in{'break_alert'} || $in{'preview'})) || $e_com){

		# 調整
		my $keep_e_com = $e_com;
		$e_com .= $a_com;

			# チェック定義
			if($in{'break_alert'}){ $break_alert_checked = $main::parts{'checked'}; }
			else{ $edit_alert_checked = $main::parts{'checked'}; }

			# アラートがあって、エラーがない場合
			if($a_com && !$keep_e_com){

					# 送信ボタンも表示する場合
					if($type =~ /View-break-button/){
						$e_com .= qq(<form method="post" action="./"><div>);
					}

				$e_com .= qq(　　<input type="radio" name="break_alert" value="0" id="edit_alert"$edit_alert_checked$main::xclose>);
				$e_com .= qq(<label for="edit_alert"> 内容を変更します</label> );
				$e_com .= qq(<input type="radio" name="break_alert" value="1" id="break_alert"$break_alert_checked$main::xclose>);
				$e_com .= qq(<label for="break_alert"> 問題ないのでこのまま送信します ( <a href="$guide_url">ルール</a> 遵守をお願いします )</label> <br$main::xclose>);
					
					# 送信ボタンも表示する場合
					if($type =~ /View-break-button/){

							# 全ての POST 内容を展開
							foreach(split(/&/,$main::postbuf)){

								# キーと値を分解
								my($key,$value) = split(/=/,$_);

								# エンコード
								my($value_decoded) = Mebius::Decode(undef,$value);

									# キーによってはエスケープ
									if($key eq "break_alert"){ next; }

									# コメント変更
									if($key eq "comment"){
										my $textarea = $value;
										$textarea =~ s/<br>/\n/g;
										$submit_button .= qq(<br$main::xclose><textarea name="comment" style="width:50%;">$value_decoded</textarea><br$main::xclose>);
									}

									# Hiiden 値で組み込む場合
									else{
										$submit_button .= qq(<input type="hidden" name="$key" value="$value_decoded"$main::xclose>);
									}
							}

						$submit_button .= qq(<input type="submit" value="送信する"$main::xclose>);
						$submit_button .= qq(</form></div>);
					}

			}
	}

	# リンクのターゲットを変更
	if($e_com && $type =~ /Target/ && !$main::kflag){
		$e_com =~ s|<a href="(.+?)">|<a href="$1" target="_blank" class="blank">|g;
	}


no strict;

	# エラーがある場合、各エラーモードに移行
	if($e_com || $in{'preview'}){
		if($rootin && $type =~ /Not-tell/){ &$rootin(); } 
		elsif($rootin){ &$rootin("$e_com"); } 
		else{ &error("$e_com$submit_button"); }
	}

}



1;

