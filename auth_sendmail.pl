
package main;

#-----------------------------------------------------------
# ���[���z�M
#-----------------------------------------------------------
sub sns_sendmail2{

my($mail,$mlpass,$toaccount,$fromaccount,$man,$sub,$url,$com,$over_text) = @_;
my($body,$subject,$text1);
my($regist,$length);


	# �������g�̏������݂̏ꍇ
	if($toaccount eq $fromaccount && !$main::myadmin_flag){ return; }

	# �����A�h�o�^�A�F�؂������ꍇ
	if($mail eq "" || $mlpass eq ""){ return; }

	# �{���̏ȗ�
	foreach( split(/<br>/,$com) ){
			if($length < 50){ $regist .= qq(${_} ); }
		$length += length $_;
	}

# �e�L�X�g�P
$text1 = qq($man > $regist);
if($over_text){ $text1 = $over_text; }

# ����
$subject = qq(�u$sub�v��$man���񂪓��e���܂����B-���r����SNS);
if($sub eq ""){ $subject = qq(���r�����r�m�r�ɍX�V������܂���); }

# �{��
$body = qq(�y���r�����r�m�r�z�ɍX�V���������̂ł��m�点���܂��B

��$text1

���t�q�k
  $auth_url$toaccount/$url


��SNS�̃��[���z�M����(�P�N���b�N)
  ${auth_url}?mode=editprof&type=cancel_mail&account=$toaccount&char=$mlpass);


# ���[�����M
if($mail ne ""){ Mebius::send_email("Edit-url-plus",$mail,$subject,$body); }

}

1;
