
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# �f���̃��[���\��
#-----------------------------------------------------------

sub bbs_rule_view{

# �錾
my($rule_text,$zatudann_text);
our($mode,$moto,$server_domain,$device_type,$divide_url,$now_url,$sub_title,$head_link3,$css_text);
our($kfontsize_h1);

# �J�e�S���ݒ���擾
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);

	# �A�N�Z�X�U�蕪��
	if($mode eq "rule"){
		$divide_url = "http://$server_domain/_$moto/krule.html";
			#if($device_type eq "mobile"){ &divide($divide_url,"mobile"); }
	}
	elsif($mode eq "krule"){
		$divide_url = "http://$server_domain/_$moto/rule.html";
			#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }
	}

	# �g�є�
	if($mode eq "krule"){ &kget_items(); }

	# �^�C�g����`
	if($mode eq "rule"){ $sub_title = "$title�̃��[��"; }
	else{ $sub_title = "$title�̃��[�� | �g�є�"; }
$now_url ="_$moto/rule.html";
$head_link3 = "&gt; ���[��";

# ���[�h����
my($rule_text,$zatudann_text,$none,$none,$pefrule_text,$category_rule) = &bbs_def_mode();

	# �J�e�S�����[���𐮌`
	if(Mebius::BBS::secret_judge()){
		$category_rule = "";
	} elsif($category_rule){
		$category_rule = qq(<h2$kfontsize_h2>$init_category->{'title'} �J�e�S���̃��[��</h2>\n$category_rule);
	}

# CSS��`
$css_text .= qq(
.rulebox{color:#222;padding:0.75em 1.5em;font-weight:bold;}
.ruleplus{border:dotted 2px #f00;padding:1em 1.25em;line-height:1.5em;}
div.text{line-height:2.3em;}
li{text-decoration:underline;line-height:2.0em;}
ol{margin-bottom:1em;}
a.marker{padding:0.2em 0.5em;margin:0em 0.5em;border:1px dotted #00f;}
);


my $print = qq(
$category_rule
<h2$kfontsize_h2>$title�̃��[��</h2>
$rule_text
<div class="text">$pefrule_text</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



#-----------------------------------------------------------
# ���[�h����
#-----------------------------------------------------------
sub bbs_def_mode{

# �錾
my($save);
my($category_rule);
our($css_text,$concept);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);


# �J�e�S���ݒ���擾
my($init_category) = Mebius::BBS::init_category_parmanent($main::category);


# CSS��`
$css_text .= qq(
.ruletitle{color:#f00;font-size:130%;}
.bmark{color:#f00;font-size:110%;}
.cmark{color:#000;font-size:110%;}
.colortext1{color:#060;}
.colortext2{color:#00b;}
);

	# ���[���\���𐮌`
	foreach(split(/\n|<br>/,$rule_text)){
		my($style);
			if($_ eq ""){ next; }
		$_ =~ s/��//g;
		$_ =~ s!<a href="(.+?)">(.+)</a>!<a href="$1" class="marker">$2</a>!g;
		if($_ =~ s/^!//g){ $_ = qq(<span style="color:#f00;">$_</span>);  $style = qq( style="color:#f00;"); }
			if($kflag){ $save .= qq($emoji_shift_jis->{'alert'}$_<br$main::xclose>\n); }
			else{ $save .= qq(<li$style>$_</li>\n); }
	}
	# �S�̐��`
	if($kflag){ $rule_text = qq($save); }
	else{ $rule_text = qq(<ol>$save</ol>\n); }

	# �J�e�S�����[���𐮌`
	my(%category) = Mebius::BBS::init_category(undef,$main::category);
	foreach(split(/\n|<br>/,$init_category->{'rule'})){
		my($style);
			if($_ eq ""){ next; }
		$_ =~ s!<a href="(.+?)">(.+?)</a>!<a href="$1" class="marker">$2</a>!g;
		if($_ =~ s/^!//g){ $_ = qq(<span style="color:#f00;">$_</span>); $style = qq( style="color:#f00;"); }
			if($kflag){ $category_rule .= qq($emoji_shift_jis->{'alert'}$_<br$main::xclose>\n); }
			else{ $category_rule .= qq(<li$style>$_</li>\n); }
	}
	# �S�̐��`
	if($category_rule){
			if($kflag){ $category_rule = qq($category_rule); }
			else{ $category_rule = qq(<ol>$category_rule</ol>\n); }
	}

# �d�����[�h�̒�`�e�L�X�g

	if($concept =~ /MODE-SOUDANN/){
		$doublemark .= qq(���d���n�j�i�����A���j);
		$doubletext .= qq(���̌f���ł́A�P���k���P�L�����g���������ǂ��悤�ȁu�l�I�ȑ��k�v�̏ꍇ�A�d���L��������Ă����܂��܂���B�������A�܂Ƃ߂���ꍇ�͋L�����܂Ƃ߂Ă��������B);
	}

	elsif($concept =~ /DOUBLE-OK/){
		$doublemark .= qq(���d���n�j);
		$doubletext .= qq(���̌f���ł́A�d���L��������Ă����܂��܂���B�������A��l�i�܂��́A����̃O���[�v�j�ŁA�����L�������������͍̂T���Ă��������B);
	}

	elsif($concept =~ /DOUBLE-GLAY/){
		$doublemark .= qq(���d���₳����);
		$doubletext .= qq(���̌f���ł́A�L���̎�ނ����Ă��Ă��A���ɕ��������Ⴆ�΍폜����܂���B�������u���܂�ɂ������e�[�}�̋L���v�͍��Ȃ��ł��������B);
	}

	elsif($concept =~ /MODE-CONCEPT/){
		$doublemark .= qq(���d���₳����);
		$doubletext .= qq(���̌f���ł́A�L���̎�ނ����Ă��Ă��A���������Ⴆ�΍폜����܂���B�������u���܂�ɂ������e�[�}�̋L���v�͍��Ȃ��ł��������B);
	}

	elsif($main::bbs{'concept'} =~ /Sousaku-mode/ && $concept !~ /NOT-DOUBLE/){

		if($category eq "diary"){
			$doublemark .= qq(���d���₳����);
			$doubletext .= qq(�L���͂Ȃ�ׂ��g���؂�܂��傤�B��l�ł��܂葽���̋L���͍��Ȃ��ł��������B);
		}

		elsif($category eq "novel" || $category eq "diary"){
			$doublemark .= qq(���d���n�j);
			$doubletext .= qq(���̌f���͑n��n�Ȃ̂ŁA�d���L�����C�ɂ��Ȃ��Ă����܂��܂���B�������A�L���̗����͂��������������B);
		}
		else{
			$doublemark .= qq(���d���₳����);
			$doubletext .= qq(���̌f���ł́A�S�������e�[�}�̋L�������Ȃ��ł��������B);
		}

	}

	elsif($concept =~ /MODE-NITCH/){
		$doublemark .= qq(�������m�f�i�j�b�`�j);
		$doubletext .= qq(���̌f���ł́A�}�j�A�b�N�Șb�育�ƂɋL�����������A�V������悲�ƂɋL��������Ă����܂��܂���B<br$main::xclose>
		���������S�ȏd����A�L���̗����͍폜�����Ă��������ꍇ������܂��B
		);
		$ngjuufukuflag = 1;
	}

	elsif($concept !~ /ZATUDANN-OK/){
		$doublemark .= qq(���d���m�f);
		$doubletext .= qq(���̌f���ł́A�d���L������邱�Ƃ͏o���܂���B���Ƃ��΁A�����Q�[����A�����A�[�e�B�X�g�̋L���͂ЂƂ܂łł��B);
		$ngjuufukuflag = 1;
	}

	else{
		$ngjuufukuflag = 1;
	}



# �G�k���[�h�̒�`�e�L�X�g

	if($concept =~ /ZATUDANN-OK1/){
		$zatudannmark .= qq(���G�k�n�j);
		$zatudanntext .= qq(���̌f���́h�G�k�n�h�ł��B���Ƀe�[�}�̂Ȃ��G�k�L���������Ă����܂��܂���B);
	}

	elsif($concept =~ /ZATUDANN-OK2/){
		$zatudannmark .= qq(���G�k�n�j�i�����A���j);
		$zatudanntext .= qq(���̌f���́h���G�k�n�h�ł��B�G�k��p�̋L��������Ă����܂��܂��񂪁A�����e�[�}�́y�d���L���z�ɂȂ�Ȃ��悤���ӂ��Ă��������B�����L�����G�k�����������Ȃ��ꍇ�́A�J�e�S���ʂ̌f���������p���������i��F�Q�[���f���Ȃǁj�B);
	}

	elsif($concept =~ /ZATUDANN-OK3|MODE-NITCH/){
	$zatudannmark .= qq(���G�k�m�f);
		$zatudanntext .= qq(���̌f���́h�J�e�S���n�h�ł��B�����G�k�͋֎~�ł��B�i�Q�O�P�O�N�X�����j);
	}
	else{
		$zatudannmark .= qq(���G�k�m�f);
		$zatudanntext .= qq(���̌f���́h�J�e�S���n�h�ł��B�G�k�L������邱�Ƃ͏o���܂���B);
	}

# �S�̃��[���̒�`

$allrulemark .= qq(<h2$kfontsize_h2>�S�̃��[��</h2>);

my($klink) = qq(-k) if($kflag);

$allruletext .= qq(�}�i�[�ᔽ�A�l���f�ځA�����A�h�L�ځA�o��s�ׁA��`�A��������AAA���͂��������������B( <a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">���ڂ����ǂ�</a> ) );
if(!$secret_mode){ $deletertext .= qq(<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">���[���ᔽ</a>���������ꍇ�́A<a href="${base_url}_delete/">�폜�˗��f����</a>�܂ł��A�����������B<a href="all-deleted$klink.html#M" rel="nofollow" class="red">�폜�ς݋L���̈ꗗ</a>������܂��B); }

# �o�b�Ȃ�}�[�N�F�Â�
if(!$kflag){
$doublemark = qq(<strong class="bmark">$doublemark</strong>);
$zatudannmark = qq(<strong class="bmark">$zatudannmark</strong>);
$allrulemark = qq(<strong class="cmark">$allrulemark</strong>);
$deletermark = qq(<strong class="cmark">$deletermark</strong>);
}

	# �o�b�łȂ�e�L�X�g�F�Â�
	if(!$kflag){
		$doubletext = qq(<span class="colortext1">$doubletext</span>);
		$zatudanntext = qq(<span class="colortext1">$zatudanntext</span>);
		$allruletext = qq(<span class="colortext2">$allruletext</span>);
		$deletertext = qq(<span class="colortext2">$deletertext</span>);
	}

# �e�L�X�g���`
$doubletext = qq(<div>$doublemark<br$main::xclose>$doubletext</div>\n);
$zatudanntext = qq(<div>$zatudannmark<br$main::xclose>$zatudanntext</div>\n);
$allruletext = qq(<div>$allrulemark $allruletext</div>\n);
$deletertext = qq(<div>$deletermark $deletertext</div>\n);

# �ŏI��`�i�V�[�N���b�g�j
if($secret_mode){
my($candel_text);
if($candel_mode){ $candel_text = qq(�����̏������݂͎���폜���Ă��������B); }
$pefrule_text = "";
$rule_text = qq(�����̃��[���̑��Ɂu�Ǘ��҂̃s���~�ߋL���v�̃��[���ɏ]���Ă��������B<br$xclose>
<a href="member.html">�������o�[���X�g�͂����炩��m�F�ł��܂��B</a><br$xclose>
����{�I�ɂ��̌f���̑��݂́A���̏ꏊ�ł͐G��Ȃ��悤�ɂ��Ă��������B
���p�X���[�h�݂̑��؂�A���L�A���n�͋֎~�ł��B�u���[�U�[���v�u�p�X���[�h�v�͖{�l�l�݂̂����g�����������B<br$xclose>
���u���r�E�X�����O�̑��̏ꏊ�v��u�O���T�C�g�v�ɁA���̌f���̂t�q�k��\\��t������A���̌f������̈��p�E�]�ڂ������Ȃ�Ȃ��ł��������B<br$xclose>
�����[���ɔ������ꍇ�ȂǁA�Ǘ��҂̓ƒf�ŁA�\\���Ȃ��Ƀ����o�[�o�^�����������Ă��������ꍇ������܂��B<br$xclose>
���폜�˗�������ꍇ�A�i�폜�˗��͗��p�����j���̌f�����ɏ������A<a href="scmail.html">�Ǘ��҈��Ƀ��[��</a>���Ă��������B$candel_text<br$xclose>
���f�����{���E���p�ł���̂́u�������o�[�v�u���҂������Ȃ����Ǘ���(�P�l)�v�݂̂ł��B�������ً}�̏ꍇ�ȂǁA�����āu�����Ǘ��ҁi���Y���}�X�^�[�j�v���Ǘ������Ă��������ꍇ������܂��B
);
}
	# �ŏI���`�i�ʏ�j
	else{
			if($kflag){ $pefrule_text .= qq($doubletext $zatudanntext $allruletext $deletertext); }
			else{ $pefrule_text .= qq(<div>$doubletext $zatudanntext $allruletext $deletertext</div>); }
	}

return($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text,$category_rule);

}


1;




1;
