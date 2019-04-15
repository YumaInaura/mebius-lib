
use strict;
package Mebius::Auth;

#-------------------------------------------------
# �V�K�o�^�E���O�C���t�H�[��
#-------------------------------------------------
sub Index{

my($type) = @_;
my(undef,$error_message) = @_ if($type =~ /Error-browse/);
my($maxlengthac,$form,$error_line,%use_header);

# Canonical����
$main::canonical = "${main::auth_url}";

# CSS��`
$main::css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
span.alert{font-size:90%;color:#f00;}
);

$main::head_link2 = qq( &gt; $main::title );

# CSS��`
$main::css_text .= qq(
.forgot{font-size:90%;color:#f00;}
);

# ���O�C���t�H�[�����擾 ( �����^�C�v�����̂܂܈��n�� )
($form) = Mebius::Auth::LoginForm($type,$error_message);

$main::meta_tag_free .= qq(\n<meta name="google-site-verification" content="maWaXY_1fhtNFnNdUn7WH2Jg36BcB1YP3TxvF8pQ3WY">);

	# �w�b�_
	if($ENV{'REQUEST_METHOD'} eq "GET"){
		$use_header{'BodyTagJavascript'} = qq( onload="document.login_form.authid.focus()");
	}


my $print = <<"EOM";
$main::footer_link
<h1>���r�E�X�����O �A�J�E���g</h1>
$error_line
$form
$main::footer_link2
EOM

Mebius::Template::gzip_and_print_all(\%use_header,$print);


exit;

}

#-----------------------------------------------------------
# ���O�C���t�H�[�����擾
#-----------------------------------------------------------
sub LoginForm{

# �錾
my($type,$error_message) = @_;
my($form,$error_line,$inputed_account,$inputed_password);
my($checked_check1,$checked_check2,$password_input_type);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
require "${init_directory}auth_prof.pl";
my($my_account) = Mebius::my_account();

		# ���`
	if($my_account->{'login_flag'}){
		Mebius::Redirect(undef,"$my_account->{'profile_url'}feed");
	} else {
		$form .= qq(
		�A�J�E���g�ɓo�^����ƁA�ȉ��̃T�[�r�X�������p���������܂��B
		<ul class="margin">
		<li>���r����SNS �i<a href="${main::guide_url}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">���悭���鎿��</a>�j</li>
		<li>���r�����E�A�h�x���`���[</li>
		</ul>
		<h2>���O�C��</h2>
		);
	}

	# �N�b�L�[�Ȃ��̏ꍇ
	if(!$main::cookie && !Mebius::Device::bot_judge()){
			if($main::in{'redirected'}){
					$form .= qq(<strong class="red">�����̊��ł́A�A�J�E���g�𔭍s�ł��܂���B�����ǉ�ʂ��X�V���Ă݂Ă��������B</strong>);
			}
			else{
				Mebius::Cookie::set_main();
				Mebius::Redirect(undef,"$basic_init->{'auth_url'}?redirected=1&$ENV{'QUERY_STRING'}");
			}
		return($form);
	}

	# ���O�C�����̏ꍇ
	if($main::pmfile && $type !~ /Error-browse/){
		$form .= qq(���Ƀ��O�C�����ł��B);
		$form .= qq(<ul class="margin">);
		$form .= qq(<li><a href="${main::auth_url}$main::pmfile/">�����Ȃ��̃v���t�B�[����</a></li>);
		$form .= qq(<li><a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">�����r�����A�h�x���`���[��</a></li>);
		$form .= qq(</ul>);
		return($form);
	}

	# �p�X���[�h���͗��̃^�C�v
	$password_input_type = "password";

	# �����`�F�b�N
	if($main::k_access || $ENV{'USER_AGENT'} =~ /3DS/){
		$checked_check1 = $main::parts{'checked'};
		$checked_check2 = $main::parts{'checked'};
	}

	if(Mebius::Query::post_method_judge()){
		$inputed_account = $main::in{'authid'};
		$inputed_password = $main::in{'passwd1'};
			if($main::in{'checkpass'}){
				$checked_check1 = $main::parts{'checked'};
				$password_input_type = "text";
			}
			if($main::in{'other'}){
				$checked_check2 = $main::parts{'checked'};
			}
	}


	# �G���[���b�Z�[�W
	if($error_message){
		$error_line = qq(<div class="line-height padding" style="background:#fee;color:#f00;">�G���[�F $error_message</div>);
		$form .= qq($error_line);
	}

# �t�H�[������
$form .= qq(
<form action="./" method="post" name="login_form" $main::sikibetu>
<div><table>
<tr>
<td class="nowrap">�A�J�E���g��
</td><td>
<input type="text" name="authid" value="$inputed_account" pattern="^[0-9a-zA-Z]+\$" class="putid">
( ��F mickjagger )

</td>
</tr>
<tr>
<td class="nowrap">�p�X���[�h</td>
<td><input type="$password_input_type" name="passwd1" value="$inputed_password" maxlength="20">
(��F Adfk432d ) 
�@ <a href="./?mode=aview-remain" class="size80">���p�X���[�h��Y��Ă��܂����ꍇ�́c</a>
</td>
</tr>
<tr><td></td><td>
<input type="submit" value="���O�C������">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="$main::in{'back'}">
<input type="hidden" name="backurl" value="$main::in{'backurl'}">
<input type="hidden" name="login_doned" value="1">
<br><br>

<input type="checkbox" name="checkpass" value="1" id="login_check1"$checked_check1>
<span class="alert"><label for="login_check1">�X�y���`�F�b�N�@�c�@���O�C���Ɏ��s�����ꍇ�A���͂����u�p�X���[�h�v���A��ʂɂ��̂܂ܕ\\�������܂��i���ɐl�����Ȃ������m�F���������j�B</label></span><br>
<input type="checkbox" name="other" value="1" id="login_check2"$checked_check2>
<span class="alert"><label for="login_check2">���̓��O�C���@�c�@�u�ꕔ�̌f���ŕM���������N�ɂȂ�Ȃ��v�u�V�`���b�g��A�}�C���O���g���Ȃ��v�Ȃǂ̕s����N����ꍇ�́A�`�F�b�N�����Ă��������B</label></span><br>


</td></tr>
</table><br>);


$form .= qq(

<a href="./?mode=aview-newform$main::backurl_query_enc">���A�J�E���g���������łȂ����́A�����炩��V�K�o�^���Ă��������B</a><br><br>

);


$form .= qq(
</div>
</form>
);

$form .= qq(<h2>���O�C�����̂�����</h2>);

$form .= qq(<ul>\n);
$form .= qq(<li>�A�J�E���g�Ƀ��[���A�h���X���o�^����Ă���ꍇ�A���O�C���������_�Ŏ����Ƀ��[�������M����܂��B\n);

$form .= qq(</ul>\n);

return($form);


}


1;

