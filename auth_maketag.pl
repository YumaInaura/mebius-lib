
use Mebius::Tag;
package main;

#-----------------------------------------------------------
# SNSタグを作成
#-----------------------------------------------------------
sub auth_maketag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$line2,$line2_plus,$line3,$line4,$i,$tag,$comment,$i_word,$i_newtag,$double_flag,$finished_text);
my($mytag_handler,$keyword_handler);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# アクセス制限
&axscheck("ACCOUNT");

# ファイルオープン
&open($file);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# キーワード整形
$tag = $in{'tag'};
($tag) = Mebius::Tag::FixTag(undef,$tag);

	# 整形
	if(!$in{'plus'}){
		$tag =~ s/(((★|！|。|ｗ)+)$)//g;
	}

# キーワードのエンコード
($enc_tag) = Mebius::Encode(undef,$tag);
#$enc_tag =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
#$enc_tag =~ tr/ /+/;

# コメント定義
$comment = $in{'comment'};
$comment =~ s/<br>//g;

# 各種エラー
if(!$postflag){ &error("GET送信は出来ません。"); }
if(!$myprof_flag && !$myadmin_flag){ &error("他メンバーのタグは登録できません。"); }
if(length($in{'tag'}) > 20*2){ &error("キーワードは全角20文字までです"); }
if(length($in{'comment'}) > $max_comment*2){ &error("コメントは全角$max_comment文字までです"); }
if($tag =~ /(http|\.jp|\.com|\.net)/){ &error("タグにＵＲＬは使えません。"); }

# 各種エラーチェック
require "${int_dir}regist_allcheck.pl";
&url_check("",$comment);
&base_change($in{'comment'});
&error_view;

# 閉鎖ファイルをチェック
open(CLOSE_IN,"<","${auth_log_directory}_closetag/${enc_tag}_close.cgi");
$top_close = <CLOSE_IN>;
my($close_key) = split(/<>/,$top_close);
if($close_key eq "0" || $close_key eq "2"){ &error("このタグは禁止されています。"); }
close(CLOSE_IN);

# キーワード＆コメント各種エラー
if (($tag =~ /^(\x81\x40|\s)+$/)||($tag eq "")) { &error("タグを入力してください。"); }
@denyword = (
'氏ね','死ね',
'うんこ','ウンコ','まんこ','マンコ','チンコ','ちんこ',
'セックス'
);
foreach(@denyword){
if(index($tag,$_) >= 0){ &error("このタグは登録できません。"); }
if(index($comment,$_) >= 0){ &error("このコメントは登録できません。"); }
}

	# キーワードエラー２
	if(!$in{'plus'}){
		my($flag,$flag2);
		if($tag =~ /(あつまれ|集まれ|来て$|来い$)/){ &error("人を集めるには掲示板をご利用ください。"); }
		if($tag =~ /(登録し|([^a-zA-Z0-9　])(or|vs|Vs|VS)([^a-zA-Z0-9　]))/){ $flag2 = 1; }
		if($tag =~ /(る|た|の|な|い|の|て|う|る|た|の|な|い|の|て|う)(人|ひと|奴)/){ $flag2 = 1; }
		if($flag2){
		&error("タグには「単語」や「名詞的なキーワード」を使ってください。またタグを使っての「掲示板利用」や「人集め」はご遠慮ください。　例： ×陽気な人、集まれ　○陽気　"); 
		}

		if($tag =~ /(に|へ)(一言)/){ $flag = 1; }
		if($tag =~ /(？$|たら$|だろう|えば$|もの$|こと$|どれが|教えて|おしえて|好きな|すきな|集め|集る|何人|\Q投票\E|が一番|で一番|オススメ|おすすめ)/){ $flag = 1; }
		if($tag =~ /(^もし|しよう|みよう|めよう|るのか|のか$|しりとり|どっち|○○|〇〇)/){ $flag = 1; }
		if(($tag =~ s/派/$&/g) >= 2){ $flag = 1; }

		#if($tag =~ /反対$/){ &error("タグでの反対活動は出来ません。"); }

		if($flag){ &error("タグを使っての「アンケート」「トライアル」はご遠慮ください。あなた自身に関係するキーワードを登録してください。"); }
		if($tag =~ /(署名)/){ &error("署名活動などをおこなう場合は、掲示板をご利用ください。"); }
		if($tag =~ /\Qタグ\E/){ &error("タグについてのタグは作れません。"); }
	}

# ロック開始
&lock("auth$file") if($lockkey);

# 追加する行
$line .= qq(1<>$tag<>\n);

# マイタグファイルを開く
my $openfile1 = "${account_directory}${file}_tag.cgi";
open($mytag_handler,"<","$openfile1");
	while(<$mytag_handler>){
		my($key2,$tag2) = split(/<>/,$_);
		if($tag2 eq $tag && $key2 eq "1"){
		if($in{'edit'}){ next; }
		else{ $double_flag++; next; }
		}
		if($key2 eq "1"){ $i++; } else { next; }
		if($i >= $maxtag){ &error("タグは$maxtag個まです。新しく登録するには、今あるタグを減らしてください。"); }
		$line .= $_;
	}
close($mytag_handler);

# マイタグファイルを書き込む
Mebius::Fileout("",$openfile1,$line);


# ロック解除
&unlock("auth$file") if($lockkey);

# ロック開始
&lock("tag$enc_tag") if($lockkey);

# キーワードファイルを開く
my($new_flag,$up_edit_flag) = (1,0);

my $openfile2 = "${auth_log_directory}_tag/$enc_tag.cgi";
open($keyword_handler,"<","$openfile2");
	while(<$keyword_handler>){
		chomp;
		my($key,$account,$name,$comment2,$deleter2,$date2) = split(/<>/,$_);
		if($account eq $pmfile && $key eq "1"){
			$new_flag = 0;
			if($in{'edit'}){
				if($comment2 eq $comment){ &error("同じ内容のコメントは登録できません。"); }
				if($in{'up'}){
					$up_edit_flag = 1;
					next;
				}
				else{
					$comment2 = $comment;
					$date2 = $main::date;
				}
		}
		else{ $double_flag++; next; }
		}
		if($key eq "1"){ $i_word++; }
		$line2 .= qq($key<>$account<>$name<>$comment2<>$deleter2<>$date2<>\n);
	}
close($keyword_handler);

	# 追加する行
	if($new_flag || $up_edit_flag){
		$line2_plus = qq(1<>$pmfile<>$pmname<>$comment<><>$main::date<>\n);
	}
$line2 = $line2_plus . $line2;

# 重複登録の場合
if($double_flag >= 2){ &error("このタグ (<a href=\"./tag-word-$enc_tag.html\">$tag</a>) は登録済みです。"); }

# キーワードファイルを書き込む
Mebius::Fileout("",$openfile2,$line2);

# ロック解除
&unlock("tag$enc_tag") if($lockkey);

# 新規登録の場合「新着タグ」「全タグ」を更新
if($new_flag){
&make_newtag("",$i_word,$tag);
&make_alltag("","",$tag);
}

# ページジャンプ
$jump_sec = $auth_jump;
if($in{'edit'}){
$jump_url = "./tag-word-$enc_tag.html";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }
$finished_text = qq(コメントを編集しました);
}
else{
$jump_url = "${file}/tag-view";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }
$finished_text = qq(新しいタグを登録しました);
}


my $print = qq($finished_text（<a href="$jump_url">→戻る</a>）。<br>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 新着タグを更新
#-----------------------------------------------------------
sub make_newtag{

# 宣言
my($type,$i_word,$tag) = @_;
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ロック開始
&lock("newtag") if($lockkey);

# 追加する行
$line3 = qq($i_word<>$tag<>$pmfile<>\n);
#$line3 = qq(1<>$tag<>$pmfile<>$pmname<>$comment<>\n);

# 新着タグファイルを開く
my $openfile3 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"<","$openfile3");
	while(<NEWTAG_IN>){
		my($num,$tag2,$account) = split(/<>/,$_);
		$i_newtag++;
		if($i_newtag > 500){ last; }
		if($tag2 eq $tag){ next; }
		$line3 .= $_;
	}
close(NEWTAG_IN);

# 新着タグファイルを書き込む
Mebius::Fileout(undef,$openfile3,$line3);


# ロック解除
&unlock("newtag") if($lockkey);

}

#-----------------------------------------------------------
# 全タグを更新
#-----------------------------------------------------------
sub make_alltag{

# 宣言
my($type,$i_word,$tag) = @_;
my($i);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ロック開始
&lock("alltag") if($lockkey);

# 追加する行
$line4 .= qq($tag\n);

# 全タグファイルを開く
my $openfile4 = "${auth_log_directory}alltag.cgi";
open(ALLTAG_IN,"<",$openfile4);
	while(<ALLTAG_IN>){
		$i++;
		if($i > 10000){ last; }
		chomp;
		if($_ eq $tag){ next; }
		$line4 .= qq($_\n);

	}
close(ALLTAG_IN);

# 全タグファイルを書き込む
Mebius::Fileout(undef,$openfile4,$line4);

# ロック解除
&unlock("alltag") if($lockkey);

}

1;
