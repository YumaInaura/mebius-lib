
package main;

#-----------------------------------------------------------
# メール配信
#-----------------------------------------------------------
sub sns_sendmail2{

my($mail,$mlpass,$toaccount,$fromaccount,$man,$sub,$url,$com,$over_text) = @_;
my($body,$subject,$text1);
my($regist,$length);


	# 自分自身の書き込みの場合
	if($toaccount eq $fromaccount && !$main::myadmin_flag){ return; }

	# メルアド登録、認証が無い場合
	if($mail eq "" || $mlpass eq ""){ return; }

	# 本文の省略
	foreach( split(/<br>/,$com) ){
			if($length < 50){ $regist .= qq(${_} ); }
		$length += length $_;
	}

# テキスト１
$text1 = qq($man > $regist);
if($over_text){ $text1 = $over_text; }

# 件名
$subject = qq(「$sub」に$manさんが投稿しました。-メビリンSNS);
if($sub eq ""){ $subject = qq(メビリンＳＮＳに更新がありました); }

# 本文
$body = qq(【メビリンＳＮＳ】に更新があったのでお知らせします。

▼$text1

▼ＵＲＬ
  $auth_url$toaccount/$url


▼SNSのメール配信解除(１クリック)
  ${auth_url}?mode=editprof&type=cancel_mail&account=$toaccount&char=$mlpass);


# メール送信
if($mail ne ""){ Mebius::send_email("Edit-url-plus",$mail,$subject,$body); }

}

1;
