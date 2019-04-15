

#-----------------------------------------------------------
# 基本設定
#-----------------------------------------------------------
sub scbase{

# 局所化
my($line,$i,$flag);
our($alocal_mode,%bbs);

# CSS定義
$css_text .= qq(
span.turn{background-color:#dee;font-size:80%;padding:0.3em 0.7em;}
img.noborder{border-style:none;}
);

	# ユーザー名を取得
	if(!$admin_mode && !$username){
		if($alocal_mode){ $username = "aura"; }
		else{ $username = $ENV{'REMOTE_USER'} || $ENV{'REDIRECT_REMOTE_USER'}; }
			#my $line;
			#foreach(keys %ENV){
			#	$line .= qq($_ ;$ENV{$_}<br>);
			#}
		if($username eq ""){ main::error("ユーザー名が指定されていません。"); }
	}

# 設定ファイルを読み込む
open(FILE_IN,"<","${int_dir}_invite/init_${secret_mode}.cgi");
my $top_init1 = <FILE_IN>; chomp $top_init1;
my $top_init2 = <FILE_IN>; chomp $top_init2;
my $top_init3 = <FILE_IN>; chomp $top_init3;
close(FILE_IN);

# 設定ファイルを解釈
($title,$allowurl_mode,$allowaddress_mode,$fastpost_mode,$freepost_mode,$candel_mode) = split(/<>/,$top_init1);
($norank_wait,$style,$setumei) = split(/<>/,$top_init2);
($scad_email,$scad_name) = split(/<>/,$top_init3);

$bbs{'setumei'} = $setumei;

# 値がない場合
if($style eq ""){ $style = "blue1"; }

# 設定値を整形
($head_title) = $title;
if($style){ $style = qq(/style/$style.css); }

# 必須設定
our $noads_mode = 1;
$concept .= qq( NOT-PV NOT-KR NOT-NEWS NOT-ADS NOT-SUPPORT MODE-SECRET);
$bbs{'concept'} = $concept;
our $noindex_flag = 1;
our $new_min_msg = 10;
our $min_msg = 2;

# 添付ファイルの最大バイト数 ( KB )
$upload_maxkbyte = 5000;

# 値の調整
$scmoto = $moto;
$scmoto =~ s/^sc//g;

	# 会員制のCookieを定義
	if(!$admin_mode){
		my(@csecret,$flag);
			foreach(split(/ /,$csecret)){
			if($_ eq $scmoto){ $flag = 1; }
			push(@csecret,$_);
			}
			if(!$flag){ push(@csecret,$scmoto); }
		$csecret = "@csecret";
	}

# アクセス履歴を取る
#if(!$admin_mode){ &secret_push_accesslog(); }

# 自分の設定を取得する
if(!$admin_mode){ &get_scmyfile(); }
}


#-----------------------------------------------------------
# アクセス履歴を取る
#-----------------------------------------------------------
sub secret_push_accesslog{

# 局所化
my($line);

# アクセス履歴に追加する行
$line .= qq($time<>$username<>$addr<>$agent<>$chandle<>$pmfile<>\n);

# アクセス履歴を開く
open(IN,"<","${int_dir}_invite/access_${secret_mode}.cgi");
	while(<IN>){
		$i++;
			if($i < 500){ $line .= $_; }
	}
close(IN);

# アクセス履歴を更新
open(FILE_OUT,">","${int_dir}_invite/access_${secret_mode}.cgi");
print FILE_OUT $line;
close(FILE_OUT);
Mebius::Chmod(undef,"${int_dir}_invite/access_${secret_mode}.cgi");

}

#-----------------------------------------------------------
# 自分の設定を取得
#-----------------------------------------------------------
sub get_scmyfile{

# メンバーファイルを開く
open(MEMBER_IN,"<","${int_dir}_invite/member_${secret_mode}.cgi");
while(<MEMBER_IN>){
chomp;
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
if($user eq $username){ ($scmy_key,$scmy_handle,$scmy_email,$scmy_emailkey,$scmy_sendmail) = ($key,$handle,$email,$emailkey,$sendmail); }
}
close(MEMBER_IN);

# メールアドレスがない場合
	#if($scmy_email eq "" && $in{'mode'} ne "member" && !$main::alocal_mode){ &error("$titleへようこそ！ この掲示板を利用するには、まず<a href=\"$script?mode=member&amp;type=vedit\">あなたのメールアドレスを設定</a>してください。（<a href=\"mailto:$scad_email\">管理者に連絡</a>）","none"); }

}


use strict;

#-----------------------------------------------------------
# お知らせメールを送信 - strict
#-----------------------------------------------------------

sub sendmail_scres{

# 局所化
my($type,$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com) = @_;
my($body1,$body2,$subject,$text,$text_length,$timeout_flag);
our($realmoto,$alocal_mode,$allowaddress_mode,$secret_mode,$head_title);
our($server_domain,$myadmin_flag,$int_dir,$username,$scmy_email);

if($alocal_mode){ $allowaddress_mode = 1; }

# リターン
if(!$allowaddress_mode){ return; }
if(!$secret_mode){ return; }

	# 本文の省略
	foreach( split(/<br>/,$i_com) ){
			if($text_length < 50){ $text .= qq(${_} ); }
		$text_length += length $_;
	}


# 件名
$subject = qq(「$i_sub」に $i_handleさん が投稿しました);

# ノーマルの文章
$body1 = qq(メビウスリングの【$head_title】に更新があったので、お知らせいたします。

▼$i_handle > $text …

▼$i_sub - $head_title
  http://$server_domain/_$realmoto/$i_postnumber.html

▼レスを表\示
  http://$server_domain/_$realmoto/$i_postnumber.html#S$i_resnumber
);

# シンプルな文章
$body2 = qq(http://$server_domain/_$realmoto/$i_postnumber.html
);

# 配信用ファイルを開く
open(SEND_IN,"<","${int_dir}_invite/member_${secret_mode}.cgi");
while(<SEND_IN>){
chomp;
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
my($body);

if(!$sendmail || $email eq ""){ next; }
elsif($sendmail eq "1"){ $body = $body1; }
elsif($sendmail eq "2") { $body = $body2; }

$body .= qq(\nメンバー設定：\nhttp://$server_domain/_$moto/?mode=member&type=vedit);

# 自分のレスの場合
if(!$myadmin_flag && ($user eq $username || $email eq $scmy_email)){ next; }

# メール送信
if($timeout_flag){ last; }
if($email ne ""){ Mebius::send_email(undef,$email,$subject,$body); }

}
close(SEND_IN);

}



1;

