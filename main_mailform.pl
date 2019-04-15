
# ��{�錾
use strict;
package Mebius::MailForm;

#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub Start{

	# ���o�C���p�̏���
	if($main::device_type eq "mobile"){ main::kget_items(); }

	# �����N�c��
	$main::sub_title = qq(���r�E�X�����O - ���[���t�H�[��);
	$main::head_link4 = qq(&gt; ���[���t�H�[��);

	# ���[�h�U�蕪��
	if($main::in{'type'} eq "sendmail"){ &SendMail(); }
	else{ &Index(); }

}

#-----------------------------------------------------------
# �t�H�[����\��
#-----------------------------------------------------------
sub Index{

# �Ǐ���
my($type) = @_;
my(undef,$error_message) = @_ if($type =~ /Error-view/);
my($form_line,$inputed_name,$inputed_email,$inputed_comment,$preview_line);

	# �������͂��`
	if($main::in{'name'} && $main::postflag){
		$inputed_name = $main::in{'name'};
	}
	else{
		$inputed_name = $main::cnam;
	}

	# �������͂��`
	if($main::in{'email'} && $main::postflag){
		$inputed_email = $main::in{'email'};
	}
	else{
		$inputed_email = $main::cemail;
	}

	# �������̖͂{��
	if($main::in{'comment'} && $main::postflag){
		$inputed_comment = $main::in{'comment'};
		$inputed_comment =~ s/<br>/\n/g;
	}
	

$form_line .= qq(
<h1$main::kstyle_h1>���r�E�X�����O ���[���t�H�[��</h1>

�����Ń��b�Z�[�W�𑗐M����ƁA���r�E�X�����O�̑����Ǘ��ҁi������䂤�܁j�ɓ͂��܂��B
);


	# �G���[��\������ꍇ
	if($error_message){
		$form_line .= qq(<div style="background:#fee;color:#f00;padding:0.5em 1.0em;margin:1em 0em;">\n);
		$form_line .= qq(�G���[�F $error_message\n);
		$form_line .= qq(</div>\n);
	}

	# �v���r���[��\������ꍇ
	if($main::postflag && $main::in{'preview'}){
		$preview_line .= qq(<div style="background:#eef;padding:1em;margin:1em 0em;">\n);
		$preview_line .= qq(�v�������[�F<br$main::xclose><br$main::xclose>\n);
		$preview_line .= qq($main::in{'comment'}\n);
		$preview_line .= qq(</div>\n);

	}

$form_line .= qq(
$preview_line
<form action="./mailform.html" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="mailform">
<input type="hidden" name="type" value="sendmail">
$main::backurl_input
<table style="margin:1em 0em;"><tr><td nowrap class="valign-top">
�����O
</td><td>

<input type="text" name="name" size="25" style="width:50%;" value="$inputed_name">
<br><span style="font-size:90%;color:#f00;">���K�{ �c �T�C�g���̕M���i�n���h���l�[���j�Ȃǂ���͂��Ă��������B</span>
</td></tr><tr><td nowrap class="valign-top">

���[���A�h���X<br>

</td><td class="line-height"><input type="text" name="email" value="$inputed_email" size="25" style="width:50%;">
<ul style="font-size:90%;color:#f00;">
<li><strong>���[���A�h���X���������̏ꍇ�͕K�����͂��Ă��������B</strong><br$main::xclose>
<li>�����ɂ�<strong>�ԐM�̕K�v������Ɣ��f�������₢���킹</strong>�ɂ��ẮA�L�����ꂽ���[���A�h���X�ւ��A�����������Ă���܂��B<br$main::xclose>
<li>�A�h���X���L���̂��A���A�폜�˗��ɂ͉������˂�ꍇ���������܂��B�܂��A�A�h���X�����ԈႢ�̏ꍇ�͓�������ԐM�ł��܂���B<br$main::xclose>
</ul>

</td></tr><tr>
<td nowrap class="valign-top">
�{��</td><td class="line-height">
<textarea name="comment" rows="6" cols="50" style="width:90%;height:200px;">$inputed_comment</textarea>


<ul style="font-size:90%;color:#f00;line-height:1.4;">
<li>���[�����M������ʂȗ��R���Ȃ��ꍇ�A������E���A���͕K��<a href="http://aurasoul.mb2.jp/_qst/" target="_blank" class="blank">���r�E�X�����O����^�c</a>�������p���������B<br>
<li>���[�����M������ʂȗ��R���Ȃ��ꍇ�A�폜�˗��͕K��<a href="http://aurasoul.mb2.jp/_delete/" target="_blank" class="blank">�폜�˗��f����</a>�������p���������B<br>
<li>�폜�˗��̏ꍇ�A<a href="http://aurasoul.mb2.jp/wiki/guid/%BA%EF%BD%FC%B0%CD%CD%EA" target="_blank" class="blank">�폜�˗��̃K�C�h</a>���Q�l�ɁA�K���u�t�q�k�v�u���X�ԁv�u�˗����R�v�Ȃǂ𖾋L���Ă��������B<br>
<li>�s��񍐂����������ۂ́A<a href="http://aurasoul.mb2.jp/wiki/guid/%C9%D4%B6%F1%B9%E7%CA%F3%B9%F0" target="_blank" class="blank">�s��񍐕\</a> �ɂ��L������������΁A�����������Ȃ邩������܂���B
<li>�Z�L�����e�B��̗��R�ŁA���[���̍T���͑��M����܂���B�L�^���K�v�ȃ��b�Z�[�W�́A���[�U�[�l���ŕۑ������肢�������܂��B<br>
</ul>

</td></tr><tr><td></td><td>
<input type="submit" name="preview" value="���̓��e�Ńv���r���[����" class="ipreview">
<input type="submit" value="���̓��e�ő��M����" class="isubmit">
</td></tr></table>
</div>
</form>

);



Mebius::Template::gzip_and_print_all({},$form_line);

exit;


}

#-----------------------------------------------------------
# ���[���𑗐M
#-----------------------------------------------------------
sub SendMail{

# �錾
my($type) = @_;
my($mail_body);
my($my_account) = Mebius::my_account();

	# �����`�F�b�N
	if(length($main::in{'comment'}) >= 2*100000){ &Index("Error-view","�{�����������܂��B"); }
	if($main::in{'comment'} =~ /^((\s|�@|<br>)+)?$/){ &Index("Error-view","�{������͂��Ă��������B"); }
	if(length($main::in{'name'}) >= 2*100){ &Index("Error-view","�����O���������܂��B"); }

	# �d���`�F�b�N
	my($redun_error) = Mebius::Redun("Read-only","Mailform-send");
	if($redun_error && !$main::myadmin_flag){
		&Index("Error-view",$redun_error);
	}

	# ���[���̏����`�F�b�N
	if($main::in{'email'}){
		my($format_error) = Mebius::mail_format("",$main::in{'email'});
			if($format_error){ &Index("Error-view",$format_error); }
	}

	# �{���̃X�p���`�F�b�N
	if($main::in{'comment'} =~ /(\[url)/){
		&Index("Error-view","�{���� $& �Ƃ����L�[���[�h�͎g���܂���B");
	}

	# �v���r���[
	if($main::in{'preview'}){
		&Index("Preview-view");
	}

# �g���b�v��t�^
my($enctrip,$handle) = main::trip($main::in{'name'});
	my $name = $handle;
	if($enctrip){ $name = "$handle��$enctrip"; }

# ���[���{��
$mail_body .= qq(������������������������-��������������������������������\n);
$mail_body .= qq(�����M���e\n);
$mail_body .= qq(��������������������������������������������������������\n\n);

$mail_body .= qq(�����O = $name\n);
$mail_body .= qq(���[���A�h���X = $main::in{'email'}\n);
$mail_body .= qq(�{�� = $main::in{'comment'}\n);

# ���[�����M
my($error_message) = Mebius::send_email("To-master",undef,"���r�E�X�����O���[���t�H�[�� - $name",$mail_body,$main::in{'email'});
	#if($error_message && $error_message != 1){ main::error($error_message); }

	# �e�X�g
	if($my_account->{'master_flag'}){
		Mebius::send_email("",$main::in{'email'},"�e�X�g���M - ���r�E�X�����O���[���t�H�[�� - $name",$mail_body);
	}

# �N�b�L�[���Z�b�g
Mebius::Cookie::set_main({ name => $main::in{'name'} , email => $main::in{'email'} },{ SaveToFile => 1 });

# �d���t�@�C�����X�V
Mebius::Redun("Renew-only","Mailform-send");

my $print = qq(���[���𑗐M���܂����B);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;