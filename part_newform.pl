
package main;

#-------------------------------------------------
# �V�K���e�O�̐�������
#-------------------------------------------------
sub bbs_newform{

# �錾
my($newwait_flag,$newwait_dayhourmin,$nextwait_dayhour,$bonusform_flag,$nextbutton_disabled);
our($mode,$selected,$moto,$server_domain,$google_oe,$sub_title,$head_link3,$css_text,$agent);
our(%in);

	# ���[�h�U�蕪���i�Q�j
	if($mode eq "kform" || $mode eq "kruleform"){ &kget_items(); }
	if($mode eq "ruleform" || $mode eq "kruleform"){ &bbs_second_newform(); }

# �^�C�g����`
$sub_title = "�V�K���e�t�H�[�� | $title";
$head_link3 = "&gt; �V�K���e�t�H�[��";

	# �X�g�b�v���[�h
	if(Mebius::Switch::stop_bbs()){
		my $print = qq(���݁A�f���S�̂œ��e��~���ł��B);
		Mebius::Template::gzip_and_print_all({},$print);
		exit;
	}

# Google�����t�H�[��
my($domain);
if($server_domain eq "aurasoul.mb2.jp"){ $domain = "aurasoul.mb2.jp"; } else{ $domain = "mb2.jp"; }
$newform_google_form = qq(
<form method="get" action="http://www.google.co.jp/search">
<div class="google_bar google_bar2">
<a href="http://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img" alt="Google"$xclose></a>
<span class="vmiddle">
<select name="sitesearch" class="site_select">
<option value="mb2.jp">���r�E�X�����O</option>
<option value="$domain/_$moto"$selected>$title</option>
<option value="">�E�F�u�S��(www)</option>
</select>
<input type="text" name="q" size="31" maxlength="255" value="" class="ginp"$xclose>
<input type="submit" name="btnG" value="Google ����"$xclose>
<input type="hidden" name="ie" value="Shift_JIS"$xclose>
$google_oe
<input type="hidden" name="hl" value="ja"$xclose>
<input type="hidden" name="domains" value="mb2.jp"$xclose>
</span></div>
</form>
);


# CSS��`
$css_text .= qq(
.google_bar2{float:none !important;margin:1em 0em !important;}
td.alert,td.alert2{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
.table2{width:100%;}
);



	# ����ʁA���[�J�����[���`�F�b�N��
	if($in{'newform_check'} == 1){

		# �`���Ԉȓ��Ƀ��X�����Ă��Ȃ��ƁA�V�K���e�ł��Ȃ�
		Mebius::BBS::PostAfterResCheck("Error-view");

		Mebius::Redirect("","ruleform.html");
	}

	# �ŏI���e�t�H�[����
	elsif($in{'newform_check'} == 2){
		if($in{'newcheck_p1'} && $in{'newcheck_p2'} && $in{'newcheck_p3'} && $in{'newcheck_p4'} && !$in{'newcheck_ng'}){ &bbs_last_newform(); }
		else{ &error("�V�K���e�̐��������m�F���������B"); }
	}
	elsif($in{'type'} eq "image"){ &bbs_last_newform(); }

# �V�K�҂����Ԃ��擾
require "${int_dir}part_newwaitcheck.pl";
($newwait_flag,$newwait_dayhourmin,$nextwait_dayhour,$bonusform_flag) = &sum_newwait();
&sum_newwait_penalty();
if($newwait_flag){ $nextbutton_disabled = $disabled; }

# ���񂽂�V�K���e�t�H�[��(�ݒ�t�@�C�����j
if($fastpost_mode || ($bbs{'concept'} =~ /Fast-post-mode/ && !$newwait_flag)){ &bbs_last_newform("FAST",$nextwait_dayhour); }

# �L���������Ȃ��ꍇ
if($bonusform_flag && !$newwait_flag){ &bbs_last_newform("FAST",$nextwait_dayhour); }

# ���s�C���f�b�N�X����A���׋L�������擾
open(IN,"$nowfile");
my$top = <IN>; chomp $top;
my($num) = split(/<>/,$top);
close(IN);


# �ő��t�H�[���̉���e�L�X�g
if($newwait_flag){ $formtext1 = qq(���݁A�҂����Ԓ��ł� ( �c�� $newwait_dayhourmin ));}
else{ $formtext1 = qq(�h$head_title�h�ւ̐V�K���e); }

# ���ʂ̒��ӏ����i�㕔�j
$newpost_guide = qq(
<strong class="size180" style="color:#f00;">���ӁI</strong><br$xclose>
<strong class="red">���̃y�[�W�̐������悭�ǂ܂Ȃ��ƁA
�L�����폜���ꂽ��A�f���ɏ������߂Ȃ��Ȃ邱�Ƃ�����܂��B<br$xclose>
���Ȃ��̍�����L�����폜�����ƁA�������V�K���e�ł��Ȃ��Ȃ�ꍇ������܂��̂ŁA�����ӂ��������B</strong><br$xclose>
���������ł����A�������ƁA�S�Ẳӏ��ɖڂ�ʂ��Ă��������B<br$xclose>
�����N����S�ă`�F�b�N���܂��傤�B�i<a href="${guide_url}%CA%CC%C1%EB%A4%C7%B3%AB%A4%AF">�ʑ��ŊJ���ƕ֗��ł�</a>�j
��<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">�V�K���e</a>������ƁA<a href="./">$title</a>�ɐV�����L���i�y�[�W�j�𑝂₷���Ƃ��o���܂��B
�ЂƂ̋L���ɂ́A$m_max��܂Ń��X�i�ԐM�j���o���܂��B
<br$xclose>
����x�A<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">�V�K���e</a>������ƁA
���ɐV�����L��������悤�ɂȂ�܂ŁA<strong class="red">$new_wait����</strong>�i�ڈ��j�قǂ̑҂����Ԃ��o���܂��B�i���ʂ̕ԐM�͂��ł���\�\\�ł��j
);


# �ŉ����`�F�b�N�t�H�[��
$lastcheck_guide = qq(
<form action="./" method="post"$sikibetu><div>
���S�Ă̊m�F���ς񂾂�A���̓��ӂ��킵���ӏ��Ƀ`�F�b�N�����āA���M�{�^���������Ă��������B<br$xclose>
<strong class="red">�i���̑O�ɁA�P���Ԃقǂ����Ă��̃y�[�W���`�F�b�N���A�����N����悭�ǂނ��Ƃ������߂��܂��j</strong>
<br$xclose>
<input type="hidden" name="mode" value="form"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="checkbox" name="newform_check" value="1" id="agree_rule"$xclose>
<strong><label for="agree_rule">�͂��A���͐V�K���e�̃��[����S�Ď��A�ӔC�������ċL�������܂��B</label></strong>
<input type="submit" value="���[���m�F���I���āA���̃y�[�W�ɐi��"$nextbutton_disabled$xclose>
</div></form>
);


# �����������擾
($juufuku_guide) = &newform_get_juufuku_guide();
($other_guide) = &newform_get_other_guide();

# HTML
my $print = qq(
<h1 style="color:#070;$main::kstyle_h1_in">$formtext1</h1>
<div style="line-height:2;">
$newpost_guide
$juufuku_guide
$other_guide
$lastcheck_guide
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���̑��̐V�K���e���[��
#-----------------------------------------------------------
sub newform_get_other_guide{

# �錾
my($line);

# ���ӏ���(����)
$line .= qq(
<h2$main::kstyle_h2>��{���[��</h2>
���V�K���e�ɂ������āA�K�����̃��[��������Ă��������B�i<strong class="red">���[���ᔽ�̋L���͍폜����܂�</strong>�j<br$xclose>
$juufuku_ng_link
��<a href="${guide_url}%A5%AB%A5%C6%A5%B4%A5%EA%B0%E3%A4%A4">�J�e�S���ɂӂ��킵���L�������</a>�i����ׂ��f���ɁA����ׂ��L�������܂��傤�j<br$xclose>
);

# ���I�ȕ\��
if($main::bbs{'concept'} =~ /Sousaku-mode/){
$line = qq(
��<a href="${guide_url}%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD">���\\�����܂܂��L���ł�<span style="font-size:140%;">���e�t�H�[���œK�؂ȃ`�F�b�N������</span></a>
�i18�Έȏ�j<br$xclose>
);
}

# �V���b�L���O�ȕ\��
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $category ne "diary"){
$line2 .= qq(��<a href="${guide_url}%A5%B7%A5%E7%A5%C3%A5%AD%A5%F3%A5%B0%A4%CA%C9%BD%B8%BD">�V���b�L���O�ȕ\\�����܂܂��L���ł�<span style="font-size:140%;">���e�t�H�[���œK�؂ȃ`�F�b�N������</span></a>
�i15�Έȏ�B�C�W����i�A�\\�͂��܂ލ�i�A�O���e�X�N��i�Ȃǁj<br$xclose>);
}

# �n��̑薼
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $category ne "diary"){ $line2 .= qq(��<a href=\"${guide_url}%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\">�L���̑薼�ɂ͍�i�����g��</a>�i�n��̕��͋C���厖�ł��j<br$xclose>); }


# ���ӏ���(���ʃ��[�h�̂�)
if($main::bbs{'concept'} !~ /Sousaku-mode/){
$line .= qq(
��<a href="${guide_url}%B5%AD%BB%F6%A4%CE%A5%B3%A5%F3%A5%BB%A5%D7%A5%C8">������₷���薼���g���A�e�[�}�͈�ɍi��B</a>�i�ǎ҂��L���������₷���Ȃ�܂��j<br$xclose>
��<a href="${guide_url}%B8%C4%BF%CD%C5%AA%A4%CA%B5%AD%BB%F6">�l�I�ȋL�������Ȃ��B</a>�i�L���͗��p�ґS���̂��̂ł��j<br$xclose>
��<a href="${guide_url}%BB%B2%B2%C3%BC%D4%A4%CE%C0%A9%B8%C2">�u�N��^�w�N�^���ʁ^���Z�n�^�E�Ɓv�ŎQ���҂����߂���A�l���W�߂��肵�Ȃ��B</a>�i�b�蒆�S�̋L���������܂��傤�j<br$xclose>
��<a href="${guide_url}%C3%B1%C8%AF%BC%C1%CC%E4">�P����������Ȃ�</a>�i�����ԁA�g����������L�������܂��傤�j<br$xclose>
��<a href="${guide_url}%C0%AD%C5%AA%A4%CA%C5%EA%B9%C6">���I�ȑ��k�A�c�_������ꍇ�́A���e�t�H�[���œK�؂ȃ`�F�b�N�����A�{���ɂ����ӏ���������</a>�i�ǂ݂����Ȃ��l���A�ǂޑO�ɍl������悤�ɂ��܂��傤�j�B<br$xclose>
);
}

# ���ӏ���(����)
$line .= qq(
$vio_link
��<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">�֑����e�i���[���ᔽ�j�����Ȃ�</a>�i���r�E�X�����O�̃��[�������΁A�L�����폜����܂���j<br$xclose>
);

return($line);

}


#-----------------------------------------------------------
# �d���L���̐�������
#-----------------------------------------------------------

sub newform_get_juufuku_guide{

# �錾
my($line,$rule_text,$zatudanntext,$doubletext,$ngjuufukuflag);
our($category,$int_dir,$xclose,$guide_url,$newform_google_form);

# ���[�h����
require "${int_dir}part_rule.pl";
($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text,$category_rule) = &bbs_def_mode();


# ���A���n��̏ꍇ�A�d���n�j�t���O���Ȃ��ꍇ
if($category eq "poemer" && $concept !~ /POEM-ONE/){
$line = qq(
<strong>�Q.�����e�[�}�̋L���ɂ���</strong><br$xclose>
����{�I�ɁA������L�������܂��g���Ă��������B<br$xclose>
�����Ȃ������܍�낤�Ƃ��Ă���L���́A�{���ɕK�v�ł����H�@
�܂���<a href="find.html">�L������</a>��E�F�u�������g���āA
���Ȃ����������L����A���Ȃ��̓��e�ړI�ɂ������L����T���Ă݂܂��傤�B
�ӂ��킵���L��������ꍇ�A�K����������g���Ă��������B
<br$xclose>
<form action="./"><div>
���ЂƂ̌f���ɁA�����e�[�}�̍�i�L���́A��͗v��܂���B
<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">�V�K���e</a>����O�ɁA
�����悤�ȃe�[�}�̍�i�L�����Ȃ����A�K�����ׂĂ��������B
<input type="hidden" name="mode" value="find"$xclose>
<input type="text" name="word" value="" size="18" style="width:10em;"$xclose>
<input type="submit" value="�L������">
</div></form>
$newform_google_form
<span class="guide">�����Ƃ��΁u���r�E�X�����O�`�S�ɒԂ鎍�`�v�Ƃ����L������肽���ꍇ�A
�u���r�E�X�v�u�����O�v�umebi�v�u�ցv�u�S�v�u�n�[�g�v�u�z���v�ȂǁA�l������F�X�ȃp�^�[�����g���Č������Ă݂Ă��������B
</span><br$xclose>
);
}

# �����A���L�Ȃǂ̏ꍇ
elsif($main::bbs{'concept'} =~ /Sousaku-mode/){
$line = qq(
<strong>�Q.�L�������J�e�S���ɂ���</strong><br$xclose>
�����Ȃ������܍�낤�Ƃ��Ă���L���́A�f���̃J�e�S���ɍ��������̂ł����H
<a href="/">�s�n�o�y�[�W</a>���m�F���āA�����Ƃӂ��킵���ꏊ������ꍇ�A������ɋL��������Ă��������B<br$xclose>
���J�e�S���I�т̗�F�@���������n�߂̐l�́u���������S�ҁv�ցB�g�����̏����́u�������g���v�ցB�|�G�����ۂ��G�b�Z�C�́u�G�b�Z�C�����P�v�ȂǂցB<br$xclose>
����x�L�������ƁA�ォ��薼����e�̕ύX�͏o���܂���B���e���悭�m�F���Ă��������B�i�v���r���[���[�h�����p���܂��傤�j<br$xclose>
����̌f���ɁA��ȏ�̋L�������ꍇ�́A�K�v�����悭�l���܂��傤�B<br$xclose>
);
}

	# �m�[�}�����[�h - �d��NG�̏ꍇ
	elsif($ngjuufukuflag){
$line .= qq(
<h2$main::kstyle_h2>�d���L���͋֎~�ł�</h2>
����{�I�ɁA������L�������܂��g���Ă��������B<br$xclose>
�����Ȃ������܍�낤�Ƃ��Ă���L���́A�{���ɕK�v�ł����H
�@<a href="find.html">�L������</a>��E�F�u�����ŁA���ɂӂ��킵���L�����o�Ă���ꍇ�A
�K����������g���Ă��������B
<br$xclose>
<form action="./"><div>
���ЂƂ̌f���ɁA�����悤�ȋL���́A��͗v��܂���B
<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">�V�K���e</a>����O�ɁA
<a href="${guide_url}%BD%C5%CA%A3%B5%AD%BB%F6">�����悤�ȋL��</a>���Ȃ����A�K���������Ă��������B
<input type="hidden" name="mode" value="find"$xclose>
<input type="hidden" name="log" value="0"$xclose>
<input type="text" name="word" value="" size="18" style="width:10em;"$xclose>
<input type="submit" value="�L������"$xclose>
</div></form>
$newform_google_form
<span class="guide">�����Ƃ��΁u���r�E�X�����O�`�S�ɒԂ鎍�`�v�Ƃ����L������肽���ꍇ�A
�u���r�E�X�v�u�����O�v�umebi�v�u�ցv�u�S�v�u�n�[�g�v�u�z���v�ȂǁA�l������F�X�ȃp�^�[�����g���Č������Ă݂Ă��������B
</span>
);
	}

# �m�[�}�����[�h - �d���n�j�C�d���₳���߂̏ꍇ
else{ $line .= qq(<h2$main::kstyle_h2>�d���L���͋֎~�ł�</h2>$doubletext); }

return($line);

}

#-----------------------------------------------------------
# �Q�Ԗڂ̃��[���m�F�t�H�[��
#-----------------------------------------------------------
sub bbs_second_newform{

# �錾
my($rule_text,$print);
our($title,$sub_title,$head_link3,$css_text,$kinputtag,$khrtag,$xclose);
our($int_dir,$guide_url);

# �J�e�S���ݒ���擾
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);

# �w�b�_�^�C�g���������N��`

# �^�C�g����`
$sub_title = "�V�K���e�t�H�[�� | $title";
$head_link3 = "&gt; �V�K���e�t�H�[��";



# CSS��`
$css_text .= qq(
div.local_rule{padding:1em;border:solid 1px #f00;line-height:1.8;}
div.check_list{line-height:1.8;}
div.promise_list{font-size:150%;line-height:1.5;text-decoration:underline;}
);

# ���[�h����
require "${int_dir}part_rule.pl";
($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text,$category_rule) = &bbs_def_mode();



	if($rule_text){ 
		$rule_text = qq(<h2 class="red"$main::kstyle_h2>��$title�̃��[��</h2>$rule_text);
	}

my(%category) = Mebius::BBS::init_category();

	if($category_rule){ 
		$category_rule = qq(<h2 class="red"$main::kstyle_h2>��$init_category->{'title'}�J�e�S���̃��[��</h2>$category_rule);
	}


# ���[�J�����[��
$print .= qq(
<form action="./" method="post"><div>
<div class="local_rule">
�V�K���e�ɂ������āA���̃��[����K������Ă��������B<br$xclose>
$rule_text
$category_rule
$zatudanntext
$doubletext
</div>
<br$xclose>�����[���͂悭�����ł��܂������H
<input type="radio" name="newcheck_p1" value="1" id="rulecheck_yes"$xclose><label for="rulecheck_yes">�͂�</label>
<input type="radio" name="newcheck_p1" value="0" id="rulecheck_no"$xclose><label for="rulecheck_no">������</label>
�@�i��������Ȃ�����<a href="http://aurasoul.mb2.jp/_qst/">����f����</a>�ցj
);


# �`�F�b�N���X�g
$print .= qq(
<h2$main::kstyle_h2>���`�F�b�N���X�g</h2>
<div class="check_list">
�S�Ă̊m�F���ς񂾂�A�ӂ��킵���ӏ��Ƀ`�F�b�N�����āA���M�{�^���������Ă��������B<br$xclose>
<strong class="red">�i���̃y�[�W���A�R�O���ȏ�������Ă�������ǂ݁A�����N����S�ă`�F�b�N���邱�Ƃ������߂��܂��j</strong><br$xclose>
�i��<a href="form.html">����������Ȃ����Ƃ�����΁A�ЂƂO�̐����ɖ߂�܂��傤</a>�j
<h3$main::kstyle_h3>���V�K���e�`�F�b�N���X�g</h3>
<div class="promise_list">
<input type="hidden" name="mode" value="form"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="newform_check" value="2"$xclose>

<input type="checkbox" name="newcheck_p2" value="1" id="newcheck_p2"$xclose>
<strong><label for="newcheck_p2">�P�D���́A$title�̃��[�J�����[����S�ė������܂����B</label></strong><br$xclose>

<input type="checkbox" name="newcheck_p3" value="1" id="newcheck_p3"$xclose>
<strong><label for="newcheck_p3">�Q�D���́A�������[���ᔽ���������ꍇ�A�\\���Ȃ��ɋL�����폜����Ă����܂��܂���B</label></strong><br$xclose>

<input type="checkbox" name="newcheck_p4" value="1" id="newcheck_p4"$xclose>
<strong><label for="newcheck_p4">�R�D���́u�J�e�S���ɂӂ��킵���Ȃ��L���v�u<a href="${guide_url}%BD%C5%CA%A3%B5%AD%BB%F6">�d���L��</a>�v�Ȃǖ��f�ȋL���A���[���ɔ�����L���͍쐬���܂���B</label></strong><br$xclose>

<input type="checkbox" name="newcheck_ng" value="1" id="newcheck_ng"$xclose>
<strong><label for="newcheck_ng">�S�D���́A���[�������S�ɂ͊m�F���Ȃ������̂ŁA�Ӗ��̂Ȃ��ӏ��ɂ��`�F�b�N�����Ă��܂��܂��B</label></strong><br$xclose>
</div>
�薼: <input type="text" name="sub" value=""$xclose>
<input type="submit" value="�S�Ă̊m�F���I���āA�V�K���e�t�H�[���ɐi��" class="isubmit"$xclose>
</div>
</div>
</form>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

#-----------------------------------------------------------
# �ŏI���e�t�H�[��
#-----------------------------------------------------------
sub bbs_last_newform{

# �錾
my($type,$nextwait_dayhour) = @_;
my($guide,$resform,$print);
our($sub_title,$head_link3,$css_text);

# �^�C�g����`
$sub_title = "�V�K���e�t�H�[�� - $title";
$head_link3 = "&gt; �V�K���e�t�H�[��";

# CSS��`
$css_text .= qq(
.sexvio{color:#f00;font-weight:bold;font-size:90%;}
td.alert{font-size:90%;border-style:none;color:#f00;padding:0em 0em 0.5em 0em;}
.ipreview{color:#00f;}
div.lastform_guide{line-height:1.4;}
);

	# ���e�t�H�[�����擾 ( PC�� )
	if(!$kflag){
		require "${int_dir}part_resform.pl";
		($resform) = &bbs_thread_form({ NewMode => 1 , GetMode => 1 });
	}

	# �閧���[�h
	if($secret_mode){ $guide = qq(���ڂ������[���ɂ��ẮA�Ǘ��҂��w�肷����̂ɏ]���Ă��������B); }

	# �{�[�i�X
	#elsif($type =~ /FAST/){
		$guide = qq(
		<strong class="red">�X���b�h�̏d��</strong>��A�V�K���e�̃��[���ᔽ�ɂ����Ӊ������B
		);
	#}

	# �ŏI���e�K�C�h(����)
	#else{
	#$guide = qq(���e��� <a href="./" class="red">$title</a>�ŊԈႢ����܂��񂩁H<br$xclose>
	#�܂�����������Ȃ��C������ꍇ�́A<a href="form.html">�V�K���e�̐���</a>��<a href="ruleform.html">���[�J�����[���̐���</a>�ɖ߂��āA���͂�ǂݒ����Ă��������B);
	#}


# �ގ��L������������
my($auto_find_line) = Mebius::BBS::AutoFindThread(undef,$in{'sub'});

if($main::postflag && !$main::in{'sub'}){ main::error("�薼����͂��Ă��������B"); }

# HTML
$print .= qq(
<h1$main::kstyle_h1>�V�K���e ($title)</h1>
<div class="lastform_guide">$guide</div>
$auto_find_line
<h2$main::kstyle_h2>���e�t�H�[��</h2>
);

	# ���e�t�H�[��
	if($kflag){
		require "${int_dir}k_form2.pl";
		($print) .= bbs_thread_form_mobile("new");
	}


$print .= qq($resform);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

package Mebius::BBS;
use strict;

#-----------------------------------------------------------
# ��������
#-----------------------------------------------------------
sub AutoFindThread{

# �錾
my($type,$subject) = @_;
my($index_handler,$line,@index_line,$i_index,$max_view);

my $plustype_autofind;
	if($main::kflag){ $plustype_autofind .= qq( Mobile-view); }
	else{ $plustype_autofind .= qq( Desktop-view); }

require "${main::int_dir}part_indexview.pl";
my($line,$hit) = Mebius::BBS::IndexFind("Now-file Subject-search $plustype_autofind",$subject,10);

		# �C���f�b�N�X�̐��`
		if($line){
				if($main::kflag){
					$line = qq(
					<h2$main::kstyle_h2>�ގ��L��</h2>
					$line
					);
				}
				else{
					$line = qq(
					<h2$main::kstyle_h2>�ގ��L��</h2>
					<table cellpadding="3" summary="�L���ꗗ" class="table2">
					<tr><th class="td0">��</th><th class="td1">�薼</th><th class="td2">���O</th><th class="td3">�ŏI</th><th class="td4"><a name="go"></a>�ԐM</th></tr>
					$line
					</table>
					);
				}
		}

return($line);

}


#-----------------------------------------------------------
# ���X���e���Ă���`���Ԉȓ��łȂ��ƁA�V�K���e�ł��Ȃ�
#-----------------------------------------------------------
sub PostAfterResCheck{

# �錾
my($type) = @_;
my($error);

	if($main::bbs{'concept'} =~ /(Res|Post)-after-res-(\d+)/){
		my $judge_type = $1;
		my $limit_hour = $2;
		require "${main::int_dir}part_history.pl";
		my($lastrestime) = main::get_reshistory("Get-lastres-time My-file",undef,undef,$main::moto);

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($lastrestime)); }

		if($lastrestime eq "" || time >= $lastrestime + ($limit_hour*60*60)){
			$error = qq(���̌f���ł́A���X�𓊍e���Ă���$limit_hour���Ԉȓ��łȂ��ƁA�V�K���e�ł��܂���B�ڂ�����<a href="rule.html">���[�J�����[��</a>�����m�F���������B);
		}
	}

	# �G���[�̈���
	if($error){
		if($type =~ /Error-view/){ main::error("$error"); }
		else{ $main::e_com .= qq(��$error<br$main::xclose>); }
	}

return($error);

}

1;
