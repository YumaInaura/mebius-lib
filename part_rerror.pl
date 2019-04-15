use Mebius::Paint;
use Mebius::Text;
use Mebius::BBS;
use Mebius::BBS::Parts;
package main;

#-----------------------------------------------------------
# �f�X�N�g�b�v�� �v���r���[�ƃG���[
#-----------------------------------------------------------
sub regist_rerror{

# �錾
my($regist_type);
our($int_dir,$echeck_flag,$css_text);

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }

#push(@css_files,"bbs_all");

# CSS��`
$css_text .= qq(
.middle{color:#f00;font-size:130%;}
.mada{color:#03f;font-weight:normal;font-style:italic;font-size:100%;}
.please_text1{color:#080;font-size:110%;}
.sexvio{color:#f00;font-size:90%;font-weight:bold;}
div.special_error{background:#fcc;padding:0.7em 1em;color:#f00;line-height:2.0em;}
div.error_line{background:#ffeaea;padding:0.7em 1em;color:#f00;line-height:2.0em;}
div.data_line{background:#9fa;padding:0.4em 0.7em;color:#051;line-height:1.8em;}
div.preview_line{background:#ddf;padding:0.4em 1.0em;color:#00f;}
div.paint_image{margin:0.5em 0em 0em 0em;}
);

# CSS��` ( ���̏����Ƃ̋��ʕ��� )
$css_text .= qq(
input.wait_input{color:#f00 !important;}
table.table2{width:100%;margin-bottom:1em;}
th.td0{width:0%;}
th.td1{width:50%;}
th.td2{width:21%;}
th.td3{width:21%;}
th.td4{width:8%;white-space:nowrap;}
);

	# �X�}�t�H��
	if($main::device{'smart_flag'}){
		$main::css_text .= qq(.body1{width:100%;}\n);
	}


# �e�\���G���A���Z�b�g
my($fasterror_line) = &rerror_set_fasterror(@_);
my($preview_line,$index_preview_line) = &rerror_set_preview();
my($error_line) = &rerror_set_error();
my($data_line) = &rerror_set_data();

# �摜�Y�t�G���A
if($main::bbs{'concept'} =~ /Upload-mode/){ &upload_setup(); }

# ���ӕ�
if(!$e_com && !$_[0]){
$please_line = qq(
<strong class="mada">
���܂��������܂�Ă��܂���B <input type="submit" value="���̓��e�ő��M����"> ���������A�ҏW�t�H�[���œ��e��ύX���Ă��������B</strong><br><br>);
}

# �^�C�g����`
$sub_title = qq(���e | $title);

# �ҏW�t�H�[����\��
if($in{'res'}){ $regist_type = " RES"; }
else{ $regist_type = " NEW"; }
require "${int_dir}part_resform.pl";
my($resform_line) = &bbs_thread_form("PREVIEW $regist_type");

# �w�b�_
&header();

# �y�[�W��\��
print qq(<div class="body1">);

# �i�r�Q�[�V���������N
my($navi_links) = Mebius::BBS::ThreadMoveLinks("Thread-top",$main::moto,$main::in{'res'});

print $navi_links;

# �t�H�[���n�܂�
print qq(
<form action="$script?regist" method="post" name="RESFORM" id="RESFORM"$formtype$sikibetu>
<div class="thread_body bbs_border">
<div class="d">
$fasterror_line
$please_line
$error_line
$data_line
$preview_line
$alert_line
</div></div>
$index_preview_line
);

# �i�r�Q�[�V���������N
# �i�r�Q�[�V���������N
my($navi_links2) = Mebius::BBS::ThreadMoveLinks("Thread-bottom",$main::moto,$main::in{'res'});

print $navi_links2;

# �y�[�W�I���
print qq($resform_line</form></div>);

# �t�b�^
&footer();

exit;

}

#-----------------------------------------------------------
# �����G���[
#-----------------------------------------------------------
sub rerror_set_fasterror{

# �Ǐ���
my($line);

# ���^�[��
if($_[0] eq ""){ return; }

# �\�����e
$line = qq(
<div class="special_error">
<strong class="red">����G���[�F</strong><br>
��$_[0]<br>
�����b�Z�[�W�ɏ]���Ă��󋵂����P����Ȃ��ꍇ�́A${mailform}���炲�A�����������܂��B<br>
�@�u�G���[���N�����ꏊ�v�u�L���̂t�q�k�v�u���m�ȃG���[���b�Z�[�W�v�ȂǏڂ����������`�����������B<br>
</div><br>
);

return($line);

}


#--------------------------------------------------------------
# ���e�G���[
#--------------------------------------------------------------

sub rerror_set_error{

# �Ǐ���
my($line,$error_text,$pleasechange_text);
our($e_com);

# ���^�[��
if(!$e_com){ return; }

# �G���[���e
$error_text = "$e_com";

# �G���[�\��
$line = qq(
<div class="error_line">
<span class="red">�G���[�F </span><br>
$error_text
$pleasechange_text
</div>
<br>
);

return($line);

}

#--------------------------------------------------------------
# �\���f�[�^
#--------------------------------------------------------------

sub rerror_set_data{

# �Ǐ���
my($up,$line,$pre_sub,$rer_option,$news_option,$next_charge);
our($nextcharge_minsec,$cgold,$pmfile,%in);

	# ���^�[��
	if($_[0] || $strong_emd){ return; }

	# �V�K���e�ł���΁i���e�f�[�^���e�ɒǉ��j
	if($in{'res'} eq ""){ $pre_sub = " &gt; <strong>�V�����L��</strong>"; }

	# ���X���e�̏ꍇ�A�������f�[�^��\��
	if($in{'res'} ne ""){
		$next_charge .= qq(�@<strong>��</strong>�@����`���[�W�� $nextcharge_minsec �ł�$text);
			if($norank_wait){ $next_charge .= qq( (�ꗥ)); }
			elsif($cgold >= 1){ $next_charge .= qq(�@( ���݂̉e���ŗL���� )); }
			elsif($cgold <= -1){ $next_charge .= qq(�@( ���݂̉e���ŕs���� )); }
	}

	# �A�b�v���邩���Ȃ���
	if($in{'res'} ne ""){
			if($in{'up'} eq "1"){ $rer_option = qq(�@�I�v�V�����F �L����<strong class="red">�A�b�v</strong>); }
			else{ $rer_option = qq(�@�I�v�V�����F �Ȃ�);}
	}

	# �g�b�v�f��
	#if($in{'news'}){ $news_option = qq( / �g�b�v�f�ڂ���); }
	#else{ $news_option = qq( / �g�b�v�f�ڂ��Ȃ�); }


# ���e�f�[�^���e ���`
$line = qq(<div class="data_line">);
$line .= qq(<strong class="middle">$smlength����</strong> �𓊍e);


#if($cgold ne ""){ $line .= qq( ( +<img src="/pct/icon/gold1.gif" alt="����" title="����"> ��$cgold�� ) ); }
$line .= qq($next_charge);
#$line .= qq(<br$main::xclose>���e��F <a href="./">$title</a> $pre_sub $rer_option $news_option);
$line .= qq(</div><br>);

return($line);

}

#--------------------------------------------------------------
# �v���r���[
#--------------------------------------------------------------

sub rerror_set_preview{

# �Ǐ���
my($line,$index_preview_line,$pre_res,$name,$id,$trip,$pre_desu);
my(%image,$image_preview);
our($new_res_concept);
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();

# ���`
$trip = qq(���g���b�v) if $enctrip;
	my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
	if($id_history_judge->{'record_flag'}){
		$id = qq(<i><a href="./" class="idory" target="_blank" class="blank">��$encid</a></i>);
	}
	else{
		$id = qq(<i>��$encid</i>);
	}

$pre_res = $in{'pre_res'} + 1;
$name = "$i_handle$trip";
	if($my_account->{'login_flag'} && $in{'account_link'}){ $name = qq(<a href="$basic_init->{'auth_url'}$my_account->{'id'}/" target="_blank" class="blank">$name</a>);} 

# ���̓G�t�F�N�g
($i_com) = Mebius::Text::Effect(undef,$i_com);

# �I�[�g�����N
($i_com) = &bbs_regist_auto_link($i_com);

# ���Xj�R���Z�v�g�ł̐��`
my($comment_style) = Mebius::BBS::CommentStyle(undef,$new_res_concept);

# �v���r���[�錾
#$pre_desu = qq(<div style="background:#cdf;padding:0.5em 1em;">�v���r���[</div><br>);
$pre_desu = qq(<div class="preview_line">�v���r���[</div><br>);

	# ���������摜
	if($in{'image_session'}){
		(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
			if($image{'post_ok'}){
				$image_preview .= qq(<div class="paint_image">);
				$image_preview .= qq(<a href="$image{'image_url_buffer'}">);
				$image_preview .= qq(<img src="$image{'samnale_url_buffer'}" alt="�Y�t�摜">);
				$image_preview .= qq(</a>);
				$image_preview .= qq(</div>);
			}

	}

	# �V�K���e�̏ꍇ
	if ($in{'res'} eq ""){
		$line .= qq(
		$pre_desu
		<b style="color:$in{'color'};">$i_sub</b><br><br>
		<div style="color:$in{'color'};">
		<b>$name</b> $id
		<br><br><span$comment_style>$i_com</span><br>$image_preview<div class="date">$date No.0</div></div><br>
		);
	}

	# ���X���e�̏ꍇ
	else{
		$line .= qq(
		$pre_desu
		<div style="color:$in{'color'};">
		<b>$name</b> $id<br><br><span$comment_style>$i_com</span><br>$image_preview
		<div class="date">$date No.$pre_res</div></div><br>
		);
	}


	# INDEX �v���r���[
	if(!$in{'res'}){
		$index_preview_line = qq(
		<table cellpadding="3" summary="�L���ꗗ" class="table2">
		<tr><th class="td0">��</th><th class="td1">�薼</th><th class="td2">���O</th><th class="td3">�ŏI</th><th class="td4"><a name="go"></a>�ԐM</th></tr>
		<tr><td><a href="./">��</a></td><td><a href="./">$i_sub</a></td><td>$i_handle</td><td>$i_handle</td><td>0��</td></tr>
		</table>
		);
	}



return($line,$index_preview_line);

}

1;
