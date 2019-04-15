
use strict;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �ҏW�t�H�[����Ɨ��y�[�W�Ƃ��ĕ\�� 
#-----------------------------------------------------------
sub auth_myform_page{

# �錾
my($type) = @_;
my(%account,$editform);
our(%in,$submode2);

# �t�@�C����`
(%account) = Mebius::Auth::File("",$in{'account'});

	# �����̃v���t�B�[���y�[�W�̏ꍇ�A�ҏW�t�H�[�����o��
	if($account{'editor_flag'}){
		if($submode2 eq "detail"){ ($editform) = &auth_myform("Detail",$account{'file'}); }
		else{ ($editform) = &auth_myform("",$account{'file'}); }
	}
	else{ main::error("�l�̐ݒ�t�H�[���ł��B"); }

# HTML����
my $print = qq($editform);

main::auth_html_print($print,"SNS�̐ݒ�",\%account);


exit;


}

#-------------------------------------------------
# �ҏW�t�H�[�� - �}�C�A�J�E���g
#-------------------------------------------------
sub auth_myform{


# �Ǐ���
my($type,$file,$plus_line) = @_;
my(%account,$logout,$valuename,$admin_input,$alert,$flowflag,$h3text,$myform);
my($submit1,$submit2,$text1,$detail_link,$select_vote,$select_crap_diary);
our($css_text,$guide_url,$myadmin_flag,%in,$xclose,$postflag,$sikibetu,$auth_url,$i_trip,$kfontsize_h2,$kflag);


# �t�@�C����`
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }

	# SNS��~��
	if($main::stop_mode =~ /SNS/){
		return(qq(���݁ASNS�͒�~���̂��߁A�v���t�B�[���͍X�V�ł��܂���B));
	}

# �A�J�E���g�t�@�C�����J��
(%account) = Mebius::Auth::File("Hash Option",$file);


# CSS��`
$css_text .= qq(
.h2_edit{background-color:transparent;border-style:none;margin:0.7em 0em;padding:0em;}
.h3_edit{margin:1em 0em 0.3em 0em;}
.editform{margin-top:0.5em;padding:1.0em 1.0em 1.0em 1.0em;border:solid 1px #f00;line-height:1.6em;}
div.editform_core{line-height:2.2em;margin:1em 0em;}
strong.option{border:solid 1px #00f;background:#eef;padding:0.2em 0.5em;margin-right:0.5em;}
.pinput{width:15em;}
.ptextarea{width:95%;height:300px;line-height:1.4em;}
.alert2{line-height:1.9em;display:inline;color:#f00;background-color:#fff;padding:0.2em 0.3em;border:solid 1px #f00;font-size:90%;margin-right:0.2em;}
div.alert{padding:0.5em;margin:0.5em;background-color:#fff;line-height:1.25em;border:solid 1px #f00;font-size:90%;color:#f00;}
div.error{line-height:1.4em;}
span.mini{font-size:80%;}
div.prev{line-height:1.4em;}
div.detail_link{text-align:right;}
#ERROR{color:#f00;background-color:transparent;border:solid 1px #f00;}
#PREV{color:#00f;background-color:transparent;border:solid 1px #00f;}
);

	# �v���r���[�̏ꍇ�A�p�����[�^��u����
	if($postflag){
		$account{'name'} = $in{'name'};
		$account{'mtrip'} = $i_trip;
		$account{'ocomment'} = $in{'ppocomment'};
		$account{'odiary'} = $in{'ppodiary'};
		$account{'osdiary'} = $in{'pposdiary'};
		$account{'orireki'} = $in{'pporireki'};
		$account{'osdiary'} = $in{'pposdiary'};
		$account{'color1'} = $in{'ppcolor1'};
		$account{'color2'} = $in{'ppcolor2'};
		$account{'myurl'} = $in{'myurl'};
		$account{'myurltitle'} = $in{'myurltitle'};
		$account{'ohistory'} = $in{'ohistory'};
		$account{'okr'} = $in{'okr'};
		$account{'allow_vote'} = $in{'allow_vote'};


		if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }
		if($in{'email'} ne ""){ $account{'email'} = $in{'email'}; }
		$account{'prof'} = qq(\n$in{'prof'});
	}


# �e�L�X�g�G���A�̉��s���`
my $form_prof = $account{'prof'};
$form_prof =~ s/<br>/\n/g;

# �g���b�v���̕�����
$valuename = $account{'name'};
if($account{'mtrip'}){ $valuename = qq($valuename#$account{'mtrip'}); }

# �Z���N�g�{�b�N�X
my($select_admin,$select_rireki,$select_kr);
my($select_diary) = select_diary("",$account{'odiary'});
my($select_comment) = select_comment("",$account{'ocomment'});
my($select_osdiary) = select_osdiary("",$account{'osdiary'},$account{'level'});
my($select_view_last_access) = select_last_access_auth(undef,%account);
my($select_color1) = select_color1("",$account{'color1'});
my($select_color2) = select_color2("",$account{'color2'});
#my($input_email) = input_email("",$file,$account{'email'},$account{'mlpass'});
my $input_email = new_input_email_area(__PACKAGE__,\%account);
my($select_mylist); # = &myurl_form_auth("",$account{'myurl'},$account{'myurltitle'});
my($select_birthday) = select_birthday_auth(undef,%account);
my($select_message) = select_message_auth(undef,%account);
my($select_catch_mail) = select_catch_mail_auth(undef,%account);

	# �ڍאݒ�
	if($type =~ /Detail/){
		($select_rireki) = &select_rireki("",$account{'orireki'},$account{'ohistory'});
		($select_kr) = &select_kr("",$file,%account);
		($select_vote) = &select_vote_authmyform("",$account{'allow_vote'});
		($select_crap_diary) = &select_crap_diary_authmyform(undef,%account);
	}

if($myadmin_flag >= 5){ ($select_admin) = &select_admin("",%account); }

# ����
$text1 = qq( <span class="mini"> �c ���r�E�X�����O�ł̊����ꏊ�Ȃǂ��L�����Ă��������B
			 <span class="red">( �l���E�����A�h�f�ځA���l��W �Ȃǂ͋֎~�ł��B<a href="${guide_url}" target="_blank" class="blank">[���[��]</a></span> )</span> );

# �Ǘ��҂̏ꍇ
if($myadmin_flag){ $admin_input = qq(<input type="hidden" name="account" value="$file"$xclose>); }

$alert = qq(
<div class="alert">�����Ӂc�v���t�B�[���͑S�Ă̐l�Ɍ��J����A�����G���W���ɂ��o�^����܂��B�d�b�ԍ��A���[���A�h���X�A�{���A�Z���Ȃǌl���͐�΂ɏ������܂Ȃ��ŉ������B</div>);

	# ���M�{�^���i�v���r���[���j
	if($kflag){
$submit1 = $submit2 = qq(
<input type="submit" name="preview" value="�m�F"$xclose>
<input type="submit" value="���M" class="isubmit"$xclose>
);
	}else{ 
$submit1 = $submit2 = qq(
<input type="submit" name="preview" value="���̓��e�Ńv���r���[����" class="ipreview"$xclose>
<input type="submit" value="���̓��e�Ŗ{�ݒ肷��" class="isubmit"$xclose>
);
	}


	# �� �ڍ׃����N�Ȃ�
	{

		$detail_link .= qq(<div class="detail_link">);

		# �p�X���[�h�Đݒ�t�H�[���ւ̃����N
		$detail_link .= qq(<a href="./?mode=aview-remain&type=reset_password_view&input_type=password">���p�X���[�h�Đݒ�</a>\n);
		$detail_link .= qq(<a href="./?mode=aview-remain&type=reset_remain_email_view&input_type=password">�������C���A�h���X�̐ݒ�</a>\n);

		# �ڍאݒ�ւ̃����N
		if($type !~ /Detail/){
			$detail_link .= qq(<a href="$auth_url$file/edit-detail#EDIT" style="color:#777;font-size:medium;">���ڍאݒ��</a>\n);
		}
		$detail_link .= qq(</div>);
	}

# �ڍ�
my $finput_detail = $in{'detail'};
if($type =~ /Detail/){ $finput_detail = "1"; }

# �t�H�[�����o��
$myform .= <<"EOM";
<form action="$auth_url" method="post"$sikibetu>
<div>
$plus_line
<h2 id="EDIT"$kfontsize_h2>�ݒ�ύX</h2>
<div class="editform">
$submit1
<div class="editform_core">
<strong class="option">�M���F</strong>
<input type="text" name="name" value="$valuename" class="pinput"$xclose>
$input_email
$select_catch_mail
$select_birthday
<strong class="option">�v���t�B�[��$text1�F</strong><br$main::xclose>
<textarea name="prof" class="ptextarea" cols="25" rows="5">$form_prof</textarea><br$xclose>
$alert
$select_color1
$select_color2
<div>
<strong class="option">���F</strong>
$select_view_last_access
$select_message
$select_diary
$select_comment
$select_osdiary
</div>

$select_mylist
$select_rireki
$select_kr
$select_vote
$select_crap_diary
</div>
$submit2
<input type="hidden" name="mode" value="editprof"$xclose>
<input type="hidden" name="detail" value="$finput_detail"$xclose>
$admin_input $detail_link
</div>
</div>
</form>
$select_admin
EOM
	
return($myform);

}



#-----------------------------------------------------------
# �a�����̐ݒ�
#-----------------------------------------------------------
sub select_birthday_auth{

# �錾
my($type,%account) = @_;
my($line,$selected_not_open,$selected_friend_open);

# �e�탊�^�[��
if(!$main::thisyear){ return(); }

# ���`
$line .= qq(<strong class="option">�a�����F</strong> );

	# ���N�̓W�J
	if($account{'birthday_year'} && !$main::myadmin_flag){
		$line .= qq($account{'birthday_year'}�N );
	}
	else{
		my(@years);
		$line .= qq(<select name="birthday_year">\n);
			$line .= qq(<option value="">���I��</option>\n);
				for($main::thisyear - 120 .. $main::thisyear - 10){
					push(@years,$_);
				}
			@years = sort { $b <=> $a } @years;
				foreach(@years){
					my $selected = $main::parts{'selected'} if($main::in{'birthday_year'} eq $_ || $account{'birthday_year'} eq $_);
					$line .= qq(<option value="$_"$selected>$_</option>\n);
				}
		$line .= qq(</select> �N\n);
	}

	# �����̓W�J
	if($account{'birthday_month'} && !$main::myadmin_flag){
		$line .= qq($account{'birthday_month'}�� );
	}
	else{
		$line .= qq(<select name="birthday_month">\n);
			$line .= qq(<option value="">���I��</option>\n);
				for(1 .. 12){
					my $selected = $main::parts{'selected'} if($main::in{'birthday_month'} eq $_ || $account{'birthday_month'} eq $_);
					$line .= qq(<option value="$_"$selected>$_</option>\n);
				}
		$line .= qq(</select> ��\n);
	}

	
	# �����̓W�J	# ���N�̓W�J
	if($account{'birthday_day'} && !$main::myadmin_flag){
		$line .= qq($account{'birthday_day'}�� );
	}
	else{
		$line .= qq(<select name="birthday_day">\n);
			$line .= qq(<option value="">���I��</option>\n);
				for(1 .. 31){
					my $selected = $main::parts{'selected'} if($main::in{'birthday_day'} eq $_ || $account{'birthday_day'} eq $_);
					$line .= qq(<option value="$_"$selected>$_</option>\n);
				}
		$line .= qq(</select> ��\n);
	}

	# ���J�ݒ�̏����`�F�b�N���`
	if($account{'birthday_concept'} =~ /Not-open/ || $main::in{'birthday_concept_open'} eq "Not-open"){
		$selected_not_open = $main::parts{'selected'};
	}
	elsif($account{'birthday_concept'} =~ /Friend-open/){
		$selected_friend_open = $main::parts{'selected'};
	}
	else{
		$selected_friend_open = $main::parts{'selected'};
	}

	#$line .= qq(�a�����̌��J�F \n);
	$line .= qq(<select name="birthday_concept_open">\n);
	$line .= qq(<option value="Not-open"$selected_not_open>�a�����͔���J</option>\n);
	$line .= qq(<option value="Friend-open"$selected_friend_open>�a������$main::friend_tag�܂Ō��J</option>\n);
	$line .= qq(</select>\n);

	if(!$account{'birthday_year'} || $main::alocal_mode){
		$line .= qq(<span style="color:#080;" class="size90">������J�ݒ�ɂ��Ă��A�����܂��ȔN��敪�͌��J�����ꍇ������܂��B</span>\n);
	}

	# ��l�}�[�N
	if($main::alocal_mode){ $line .= qq( ��l�F $account{'adult_flag'}); }

$line = qq(<div>$line</div>);


return($line);

}

#-----------------------------------------------------------
# ���b�Z�[�W�{�b�N�X�̗��p
#-----------------------------------------------------------
sub select_message_auth{

# �錾
my($type,%account) = @_;
my($line,$selected_use,$selected_friend_only,$selected_not_use,$selected_deny_use);

# ���[�������p�ł��Ȃ��ꍇ
if(!$account{'allow_message_status'}){ return(); }

	# �����`�F�b�N���`
	if($main::postflag){
			if($main::in{'allow_message'} eq "Use"){ $selected_use = $main::parts{'selected'}; }
			if($main::in{'allow_message'} eq "Friend-only"){ $selected_friend_only = $main::parts{'selected'}; }
			if($main::in{'allow_message'} eq "Not-use"){ $selected_not_use = $main::parts{'selected'}; }
			if($main::in{'allow_message'} eq "Deny-use"){ $selected_deny_use = $main::parts{'selected'}; }
	}
	else{
			if($account{'allow_message'} eq "Use" || $account{'allow_message'} eq ""){ $selected_use = $main::parts{'selected'}; }
			if($account{'allow_message'} eq "Friend-only"){ $selected_friend_only = $main::parts{'selected'}; }
			if($account{'allow_message'} eq "Not-use"){ $selected_not_use = $main::parts{'selected'}; }
			if($account{'allow_message'} eq "Deny-use"){ $selected_deny_use = $main::parts{'selected'}; }
	}

# ��`
$line .= qq(���b�Z�[�W�F );
$line .= qq(<select name="allow_message">);
$line .= qq(<option value="Use"$selected_use>���p���� - �S�����o�[</option>\n);
$line .= qq(<option value="Friend-only"$selected_friend_only>���p���� - $main::friend_tag�̂�</option>\n);
$line .= qq(<option value="Not-use"$selected_not_use>���p���Ȃ�</option>\n);
	if($main::myadmin_flag){
		$line .= qq(<option value="Deny-use"$selected_deny_use>���p�֎~(�Ǘ��Ґݒ�)</option>\n);
	}

$line .= qq(</select>);

return($line);


}

#-----------------------------------------------------------
# ���m�点���[���̎�M�ݒ�
#-----------------------------------------------------------
sub select_catch_mail_auth{

# �錾
my($type,%account) = @_;
my($line);
my($selected_message_catch,$selected_message_not_catch);
my($selected_resdiary_catch,$selected_resdiary_not_catch);
my($selected_comment_catch,$selected_comment_not_catch);
my($selected_etc_catch,$selected_etc_not_catch);

	# ���[�����F�؂���Ă��Ȃ��ꍇ�̓��^�[��
	if(!$account{'remain_email'}){ return(); }

	#�� ���[���̎�M�ݒ� - ���b�Z�[�W
	if($account{'allow_message_flag'}){
			if($main::in{'catch_mail_message'} eq "Not-catch" || (!$main::postflag && $account{'catch_mail_message'} eq "Not-catch")){
				$selected_message_not_catch = $main::parts{'selected'};
			}
			else{
				$selected_message_catch = $main::parts{'selected'};
			}
		$line .= qq(<select name="catch_mail_message">\n);
		$line .= qq(<option value="Catch"$selected_message_catch>���b�Z�[�W - ��M����</option>\n);
		$line .= qq(<option value="Not-catch"$selected_message_not_catch>���b�Z�[�W - ��M���Ȃ�</option>\n);
		$line .= qq(</select>\n);
	}

	#�� ���[���̎�M�ݒ� - ���L�ւ̃��X
	if($main::in{'catch_mail_resdiary'} eq "Not-catch" || (!$main::postflag && $account{'catch_mail_resdiary'} eq "Not-catch")){
		$selected_resdiary_not_catch = $main::parts{'selected'};
	}
	else{
		$selected_resdiary_catch = $main::parts{'selected'};
	}
	$line .= qq(<select name="catch_mail_resdiary">\n);
	$line .= qq(<option value="Catch"$selected_resdiary_catch>���L�ւ̃��X - ��M����</option>\n);
	$line .= qq(<option value="Not-catch"$selected_resdiary_not_catch>���L�ւ̃��X - ��M���Ȃ�</option>\n);
	$line .= qq(</select>\n);


	#�� ���[���̎�M�ݒ� - �`���ւ̏������� ( �����`�F�b�N���t )
	if($main::in{'catch_mail_comment'} eq "Catch" || (!$main::postflag && $account{'catch_mail_comment'} eq "Catch")){
		$selected_comment_catch = $main::parts{'selected'};
	}
	else{
		$selected_comment_not_catch = $main::parts{'selected'};
	}
	$line .= qq(<select name="catch_mail_comment">\n);
	$line .= qq(<option value="Catch"$selected_comment_catch>�`���ւ̓��e - ��M����</option>\n);
	$line .= qq(<option value="Not-catch"$selected_comment_not_catch>�`���ւ̓��e - ��M���Ȃ�</option>\n);
	$line .= qq(</select>\n);

	#�� ���[���̎�M�ݒ� - ���̑�
	if($main::in{'catch_mail_etc'} eq "Not-catch" || (!$main::postflag && $account{'catch_mail_etc'} eq "Not-catch")){
		$selected_etc_not_catch = $main::parts{'selected'};
	}
	else{
		$selected_etc_catch = $main::parts{'selected'};
	}
	$line .= qq(<select name="catch_mail_etc">\n);
	$line .= qq(<option value="Catch"$selected_etc_catch>���̑� - ��M����</option>\n);
	$line .= qq(<option value="Not-catch"$selected_etc_not_catch>���̑� - ��M���Ȃ�</option>\n);
	$line .= qq(</select>\n);


	# ���`
	if($line){ $line = qq(<div><strong class="option">���m�点���[���F</strong> $line</div>); }


return($line);

}

#-------------------------------------------------
# �ѐF�̎w��
#-------------------------------------------------

sub select_color1{

# �錾
my($type,$color1) = @_;
my($select_color1,@color1);
our($selected);

@color1 = (
"�_=ccc",
"��=faa",
"��=f9b",
"�g=f97",
"��=fc7",
"�X=7c7",
"��=7d3",
"�C=8ca",
"��=6cc",
"��=acf",
"��=b9c",
"�d=eae",
"��=c88",
"��=ee3=",
"��=dd5=",
"��=fd9"
);


$select_color1 .= qq(<strong class="option">�F�F</strong> �сF<select name="ppcolor1">);
$select_color1 .= qq(<option value="">����</option>\n); 

	foreach(@color1){
		my($name,$code) = split(/=/,$_);
		if($code eq $color1){ $select_color1 .= qq(<option value="$code" style="background-color:#$code;"$selected>$name</option>\n); }
		else{ $select_color1 .= qq(<option value="$code" style="background-color:#$code;">$name</option>\n); }
	}

$select_color1 .= qq(</select>);

return($select_color1);

}

#-----------------------------------------------------------
# �����F�̐ݒ�
#-----------------------------------------------------------
sub select_color2{

# �錾
my($type,$color2) = @_;
my($select_color2,@color);
our($selected);

(@color) = Mebius::Init::Color();

$select_color2 .= qq( ���L�F<select name="ppcolor2">);

	foreach(@color){
		my($name,$code) = split(/=/,$_);
		$code =~ s/#//g;
			if($code eq $color2){ $select_color2 .= qq(<option value="$code" style="color:#$code;"$selected>$name</option>\n); }
			else{ $select_color2 .= qq(<option value="$code" style="color:#$code;">$name</option>\n); }
	}

$select_color2 .= qq(</select>);

return($select_color2);

}

#-----------------------------------------------------------
# �����A�h
#-----------------------------------------------------------
sub new_input_email_area{

my $self = shift;
my $account_data = shift;
my($return);
my $html = new Mebius::HTML;

$return .= qq(<strong class="option">���[���A�h���X(����J)�F</strong>);
	if($account_data->{'remain_email'}){
		$return .= e($account_data->{'remain_email'});
	} else {
		$return .= qq(�o�^�Ȃ�);
	}

$return .= " ( " . $html->href("./?mode=aview-remain&type=reset_remain_email_view&input_type=password","���ύX") . " )";

$return;

}


#-------------------------------------------------
# �����A�h�o�^
#-------------------------------------------------
sub input_email{

my($type,$file,$email,$mlpass) = @_;
my($value,$disabled1,$text1,$checkd,$input_email,$checked1);
our(%in,$xclose,$disabled,$checked,$alocal_mode,$auth_url);

$text1 = qq(<div class="alert"><span style="color:#f00;font-size:small;">
�����[���A�h���X����͂���ƁA���L�ɃR�����g���������Ƃ��ȂǁA���m�点���[�����͂��܂��B
�������C�^�Y���h�~�̂��߁A�����ǔF�ؗp�̃��[�������s����A�ڑ��f�[�^�Ȃǂ��ꏏ�ɑ��M����܂��B
</span></div>);

	if($email){
		$value = $email;
		$text1 = qq(<div class="alert">���F�؂��ς�ł��܂���B�ݒ�ύX�������Ȃ��ƃ��[�������s�����̂ŁA���[���{�b�N�X���J���ĔF�؍�Ƃ����������Ă��������B</div>);
	}
	if($mlpass){
		$disabled1 = $disabled;
		$text1 = qq(<div class="alert2">�F�؍ς�</div>);
	}

	# ���[�J���p�̉����p�t�q�k
	if($alocal_mode && $mlpass){
		$text1 .= qq( (<a href="$auth_url?mode=editprof&amp;type=cancel_mail&amp;account=$file&char=$mlpass">���z�M���[���������(Alocal)</a>));
	}

$input_email .= qq(�@<strong class="option">���[���A�h���X(����J)�F</strong>);

if($in{'reset_email'}){ $checked1 = $checked; }
if($disabled1){ $input_email .= qq(<input type="text" name="none" value="$value" class="pinput"$disabled1$xclose> ); }
else{ $input_email .= qq(<input type="text" name="email" value="$value" class="pinput"$xclose> ); }

$input_email .= qq( $text1 );
if($mlpass){ $input_email .= qq( <input type="checkbox" name="reset_email" value="1" id="reset_email"$checked1$xclose><label for="reset_email">���[���A�h���X���폜</label><br$main::xclose>); }
$input_email .= qq(<input type="hidden" name="certype" value="sns"$xclose>);

return($input_email);

}

#-----------------------------------------------------------
# ���O�C�����Ԃ̕\��
#-----------------------------------------------------------
sub select_last_access_auth{

# �錾
my($type,%account) = @_;
my($line,$selected_open,$selected_not_open,$selected_friend_only);


	# �����`�F�b�N
	if((!$main::postflag && $account{'allow_view_last_access'} eq "Not-open") || $main::in{'allow_view_last_access'} eq "Not-open"){
		$selected_not_open = $main::parts{'selected'};
	}
	elsif((!$main::postflag && $account{'allow_view_last_access'} eq "Friend-only") || $main::in{'allow_view_last_access'} eq "Friend-only"){
		$selected_friend_only = $main::parts{'selected'};
	}
	else{
		$selected_open = $main::parts{'selected'};
	}

# ���O�C�����Ԃ̕\��
$line .= qq(���O�C�����ԁF \n);
$line .= qq(<select name="allow_view_last_access">\n);
$line .= qq(<option value="Open"$selected_open>���O�C�����[�U�[�ɕ\\��</option>\n);
$line .= qq(<option value="Friend-only"$selected_friend_only>$main::friend_tag�����ɕ\\��</option>\n);
$line .= qq(<option value="Not-open"$selected_not_open>�\\�����Ȃ�</option>\n);
$line .= qq(</select>\n);

# ���^�[��
return($line);


}

#-------------------------------------------------
# ���L�ւ̃R�����g�󂯕t��
#-------------------------------------------------
sub select_diary{

# �Ǐ���
my($type,$odiary) = @_;
my($select0,$select1,$select2,$select_diary);
our($selected);

if($odiary eq "0"){ $select0 = $selected; }
elsif($odiary eq "2"){ $select2 = $selected; }
else{ $select1 = $selected; }

# �R�����g��t�̐ݒ蕔��
$select_diary .= <<"EOM";
���L�F
<select name="ppodiary">
<option value="1"$select1> �S�����o�[�ɃR�����g����</option>
<option value="2"$select2> �}�C���r�ɃR�����g����</option>
<option value="0"$select0> ���������ɃR�����g����</option>
EOM

$select_diary .= qq(</select>);

return($select_diary);

}

#-------------------------------------------------
# �`���ւ̃R�����g�󂯕t��
#-------------------------------------------------
sub select_comment{

# �Ǐ���
my($type,$ocomment) = @_;
my($select0,$select1,$select2,$select3,$select9,$select_comment);
our($xclose,$selected);

if($ocomment eq "0"){ $select0 = $selected; }
elsif($ocomment eq "2"){ $select2 = $selected; }
elsif($ocomment eq "3"){ $select3 = $selected; }
else{ $select1 = $selected; }

# �R�����g��t�̐ݒ蕔��
$select_comment .= <<"EOM";
�`���F
<select name="ppocomment">
<option value="1"$select1> �S�����o�[�ɃR�����g����</option>
<option value="2"$select2> �}�C���r�ɃR�����g����</option>
<option value="0"$select0> ���������ɃR�����g����</option>
<option value="3"$select3> �`����\\�����Ȃ�</option>
EOM

$select_comment .= qq(</select>);

# �ݒ�̒���
$select_comment .= <<"EOM";
<br$xclose><div class="alert">
�����Ӂc�`���́A�������o�[����̍폜�˗��ɂ��g���܂��B
��{�I�Ɂu�S�����o�[�ɋ�����v��I��ł��������B
���Ȃ��̃A�J�E���g�Ń��[���ᔽ���Ȃ��Ɗm�M�ł���ꍇ�����A
�u�}�C���r�ɂ���������v�u�����ɂ���������v��I��ł��������B
</div>
EOM

return($select_comment);

}



#-------------------------------------------------
# ���L�\���ݒ�̃Z���N�g�{�b�N�X
#-------------------------------------------------
sub select_osdiary{

# �Ǐ���
my($type,$osdiary,$level) = @_;
my($select0,$select1,$select2,$select_osdiary);
my($parts) = Mebius::Parts::HTML();

	# �����`�F�b�N
	if($level < 1){ return(); }

	# �`�F�b�N
	if($osdiary eq "0"){ $select0 = $parts->{'selected'}; }
	elsif($osdiary eq "2"){ $select2 = $parts->{'selected'}; }
	else{ $select1 = $parts->{'selected'}; }

# �R�����g��t�̐ݒ蕔��
$select_osdiary .= <<"EOM";
���L�{���F
<select name="pposdiary">
<option value="1"$select1> �S�����o�[�ɕ\\������</option>
<option value="2"$select2> �}�C���r�����ɕ\\������</option>
<option value="0"$select0> ���������ɕ\\������</option>
EOM

$select_osdiary .= qq(</select>);

return($select_osdiary);

}

#-----------------------------------------------------------
# �L�̗��p
#-----------------------------------------------------------
sub select_vote_authmyform{

# �Ǐ���
my($type,$allow_vote) = @_;
my($line,$select_not,$select_use);
our($selected);

	# �I��
	if($allow_vote eq "not-use"){ $select_not = $selected; }
	else{ $select_use = $selected; }

# �R�����g��t�̐ݒ蕔��
$line .= qq(
<select name="allow_vote">
<option value="use-open"$select_use>�L���󂯎��</option>
<option value="not-use"$select_not>�L���󂯎��Ȃ�</option>
);

$line .= qq(</select>);

# ���^�[��
return($line);

}


#-----------------------------------------------------------
# �L�̗��p
#-----------------------------------------------------------
sub select_crap_diary_authmyform{

# �Ǐ���
my($type,%account) = @_;
my($line,$select_not,$select_use);

	# �I��
	if($account{'allow_crap_diary'} eq "Deny" || ($main::in{'allow_crap_diary'} eq "Deny" && $main::postflag)){ $select_not = $main::parts{'selected'}; }
	else{ $select_use = $main::parts{'selected'}; }

# �R�����g��t�̐ݒ蕔��
$line .= qq(
<select name="allow_crap_diary">
<option value="Allow"$select_use>���L�ւ̂����ˁI������</option>
<option value="Deny"$select_not>���L�ւ̂����ˁI������</option>
);

$line .= qq(</select>);

# ���^�[��
return($line);

}


#-------------------------------------------------
# ���e����\���̃Z���N�g�{�b�N�X
#-------------------------------------------------
sub select_rireki{

# �Ǐ���
my($type,$orireki,$ohistory) = @_;
my($select0,$select1,$select2,$select_rireki);
my($bselect_use_open,$bselect_use_close,$bselect_not_use);
our($auth_url,$selected);

# �I��
if($orireki eq "0"){ $select0 = $selected; }
else{ $select1 = $selected; }

# �R�����g��t�̐ݒ蕔��
$select_rireki .= <<"EOM";
<br><br><strong class="option">�ڍׁF</strong>
<select name="pporireki">
<option value="1"$select1>�f���̓��e�������g��</option>
<option value="0"$select0> �f���̓��e�������g��Ȃ�</option>
EOM
$select_rireki .= qq(</select>);

# SNS�̍s������
if($ohistory eq "not-use"){ $bselect_not_use = $selected; }
elsif($ohistory eq "use-close"){ $bselect_use_close = $selected; }
else{ $bselect_use_open = $selected; }

#<option value="not-use"$bselect_not_use> SNS�̍s���������g��Ȃ�</option>

# �R�����g��t�̐ݒ蕔��
$select_rireki .= qq(
<select name="ohistory">
<option value="use-open"$bselect_use_open>SNS�̍s���������g��(���J)</option>
<option value="use-close"$bselect_use_close>SNS�̍s���������g��(����J)</option>
</select>
);


return($select_rireki);

}

#-------------------------------------------------
# ���e����\���̃Z���N�g�{�b�N�X
#-------------------------------------------------
sub select_kr{

# �Ǐ���
my($type,$file,%account) = @_;
my($select_not_use,$select_use_open,$line);
our($selected);

# �I��
if($account{'okr'} eq "not-use"){ $select_not_use = $selected; }
else{ $select_use_open = $selected; }

# �R�����g��t�̐ݒ蕔��
$line .= qq(
<select name="okr">
<option value="use-open"$select_use_open>�֘A�����N���g��</option>
<option value="not-use"$select_not_use>�֘A�����N���g��Ȃ��i�L���\\���j</option>
</select>
);

return($line);

}

#-------------------------------------------------
# �Ǘ��҂݂̂̐ݒ�t�H�[��
#-------------------------------------------------
sub select_admin{

# �Ǐ���
my($type,%account) = @_;
my($unblock_line,$unblock_date);
my($select_admin,$selected_nolimit_account_lock,$period_line);
our($int_dir,$auth_url,%in);

# ��荞�ݏ���
require "${int_dir}part_delreason.pl";
require "${main::int_dir}auth_edit.pl";

# �������̎擾
$unblock_line .= qq(<select name="ppblocktime">);

	# ���Ɋ����t����������Ă���ꍇ
	if($account{'blocktime'}){
		$unblock_date = gettime_unblock($account{'blocktime'});
		$unblock_line .= qq(<option value="$account{'blocktime'}">$unblock_date</option>\n);
	}


	# �������A�J�E���g���b�N�̏ꍇ
	if($account{'key'} eq "2" && !$account{'blocktime'}){
		$selected_nolimit_account_lock = $main::parts{'selected'};
	}


$unblock_line .= qq(<option value="none">�Ȃ�</option>\n);
$unblock_line .= qq(<option value="forever"$selected_nolimit_account_lock>������</option>\n);

my($option_deny_select) = shift_jis(Mebius::Reason::get_select_denyperiod()); # part_delreason.pl ����
$unblock_line .= qq($option_deny_select);
$unblock_line .= qq(</select>);

# �x��/�폜���R�t�H�[��
my($select_reason) = shift_jis(Mebius::Reason::get_select_reason($account{'reason'},"ACCOUNT"));

$select_admin .= qq(
<h2 id="BASEEDIT" class="h2_edit">�Ǘ��ݒ�t�H�[��</h2>
<form action="$auth_url" method="post">
<div>
�L�[<br><input type="text" name="ppkey" value="$account{'key'}">
�x�� <select name="ppreason">$select_reason</select> ������ $unblock_line);

$select_admin .= qq(<div class="margin">);

	# �O��̃��b�N����
	if($account{'last_locked_period'}){
		my($how_locked) = Mebius::SplitTime("Not-get-second Not-get-minute Not-get-hour",$account{'last_locked_period'});
		$period_line .= qq( �� �O��̃��b�N���ԁF $how_locked);
		my($how_locked_all) = Mebius::SplitTime("Not-get-second Not-get-minute Not-get-hour",$account{'all_locked_period'});
		$period_line .= qq( �� �S���b�N���ԁF $how_locked_all);
	}

	# �ŏI�Ǘ�����
	if($account{'adlasttime'}){ 
		my(%time) = Mebius::Getdate("Get-hash",$account{'adlasttime'});
		$select_admin .= qq(�@�ŏI�Ǘ��F $time{'date'} �� ���b�N�񐔁F $account{'account_locked_count'} $period_line);
		$select_admin .= qq( �� �x����: $account{'alert_count'} );
	}

$select_admin .= qq(</div>);

$select_admin .= qq(
<br>
���x���P�i�閧����j<br> <input type="text" name="pplevel" value="$account{'level'}"><br>
���x���Q�i�r�o����j<br> <input type="text" name="pplevel2" value="$account{'level2'}"><br>
�`���b�g<br> <input type="text" name="ppchat" value="$account{'chat'}"><br>
�o�^�t�q�k<br> <input type="text" name="ppsurl" value="$account{'surl'}"><br>
�Ǘ���<br> <input type="text" name="ppadmin" value="$account{'admin'}"><br>
<br><br>
<input type="submit" value="���̓��e�ŊǗ��Ґݒ肷��">
<input type="hidden" name="mode" value="baseedit">
<input type="hidden" name="account" value="$in{'account'}">
</div>
</form>
);

return($select_admin);

}

#-----------------------------------------------------------
# ���C�ɓ���L���̓o�^
#-----------------------------------------------------------
sub myurl_form_auth{

# �錾
my($type,$myurl,$myurltitle) = @_;
my($line);

# URL�ݒ肪�Ȃ��ꍇ
if($myurl eq ""){ $myurl = qq(http://); }

# ��`
$line = qq(
<strong class="option">�}�C�t�q�k�F</strong>
URL <input type="text" name="myurl" value="$myurl">
�^�C�g�� <input type="text" name="myurltitle" value="$myurltitle">
<span class="guide">*����URL����ASNS�ȊO�B</span>
);

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# �������̓��ɂ����X�g�擾
#-----------------------------------------------------------
sub gettime_unblock{

# �錾
my($thistime) = @_;

my($thissec,$thismin,$thishour,$today,$mon,$year,$wday) = (localtime($thistime))[0..6];
my $thismonth = $mon+1;
my $thisyear = $year+1900;

# �����̃t�H�[�}�b�g
my($date) = sprintf("%04d/%02d/%02d", $thisyear,$thismonth,$today);

# ���^�[��
return($date);

}





1;
