

#-----------------------------------------------------------
# ���[�h����
#-----------------------------------------------------------
sub bbs_def_mode{

# �錾
my($save);
our($css_text,$concept);

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
			if($_ eq ""){ next; }
		$_ =~ s/��//g;
			if($kflag){ $save .= qq($emoji{'alert'}$_<br$main::xclose>\n); }
			else{ $save .= qq(<li>$_</li>\n); }
	}
	# �S�̐��`
	if($kflag){ $rule_text = qq($save); }
	else{ $rule_text = qq(<ol>$save</ol>); }

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
		$doubletext .= qq(���̌f���ł́A�L���̎�ނ����Ă��Ă��A���ɕ��������Ⴆ�΍폜����܂���B�������u���܂�ɂ������R���Z�v�g�̋L���v�͍��Ȃ��ł��������B);
	}

	elsif($concept =~ /MODE-CONCEPT/){
		$doublemark .= qq(���d���₳����);
		$doubletext .= qq(���̌f���ł́A�L���̎�ނ����Ă��Ă��A���ɕ��������Ⴆ�΍폜����܂���B�������u���܂�ɂ������R���Z�v�g�̋L���v�͍��Ȃ��ł��������B);
	}

	elsif($sousaku_mode && $concept !~ /NOT-DOUBLE/){

		if($category eq "diary"){
			$doublemark .= qq(���d���₳����);
			$doubletext .= qq(�L���͂Ȃ�ׂ��g���؂�܂��傤�B��l�ł��܂葽���̋L���͍��Ȃ��ł��������B);
		}

		elsif($category eq "novel" || $category eq "diary"){
			$doublemark .= qq(���d���n�j);
			$doubletext .= qq(���̌f���͑n��n�Ȃ̂ŁA�d���L�����C�ɂ��Ȃ��Ă����܂��܂���B�������A��l�i�܂��́A����̃O���[�v�j�ŋL������肷����̂́A�T���Ă��������B);
		}
		else{
			$doublemark .= qq(���d���₳����);
			$doubletext .= qq(���̌f���ł́A�S�������R���Z�v�g�̋L�������Ȃ��ł��������B);
		}

	}

	elsif($concept =~ /MODE-NITCH/){
		$doublemark .= qq(���d���m�f�i�j�b�`�j);
		$doubletext .= qq(���̌f���ł́A�d���L������邱�Ƃ͏o���܂���B<br$xclose>
		�R���Z�v�g�̂Ȃ��u�����L���v�u�P�Ȃ���L���v�́A�قڏd������̂Œ��ӂ��Ă��������i<a href="${guide_url}%A5%B8%A5%E3%A5%F3%A5%EB%CA%AC%A4%B1">�W�����������̃K�C�h���Q��</a>�j�B<br$xclose>
		�������A���Ƃ��΁u��i�`�̍U���@�v�Ɓu��i�`�̃L�����ɂ��āv�Ƃ�����̋L���́A�R���Z�v�g���Ⴄ�̂ō���Ă��܂��܂���B
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
$zatudanntext .= qq(���̌f���́h�G�k�n�h�Ȃ̂ŁA�G�k�L���������Ă����܂��܂���B���ɃR���Z�v�g���Ȃ��Ă��n�j�ł��B);
}

elsif($concept =~ /ZATUDANN-OK2/){
$zatudannmark .= qq(���G�k�n�j�i�����A���j);
$zatudanntext .= qq(���̌f���́h���G�k�n�h�ł��B�G�k�L���������Ă����܂��܂��񂪁A�u�R���Z�v�g�̎����G�k�L���i�d���L���j�v�͍폜�ΏۂȂ̂ŁA���ӂ��Ă��������B�u�R���Z�v�g�̂Ȃ��A�����̎G�k�L���v�͏d�����₷���ł��B);
}

elsif($concept =~ /ZATUDANN-OK3/){
$zatudannmark .= qq(���G�k�n�j�i�����A���j);
$zatudanntext .= qq(���̌f���ł͎G�k�L������邱�Ƃ��o���܂����A���̃J�e�S���ƑS���֌W�Ȃ����̂͋֎~�ł��B);
}


else{
$zatudannmark .= qq(���G�k�m�f);
$zatudanntext .= qq(���̌f���́h�J�e�S���n�h�ł��B�G�k�L������邱�Ƃ͏o���܂���B);
}

# �S�̃��[���̒�`

$allrulemark .= qq(���S�̃��[��);
if(!$secret_mode){ $deletermark .= qq(���폜�˗�); }

my($klink) = qq(-k) if($kflag);

$allruletext .= qq(<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">���r�E�X�����O�֑�</a>����{���[���ł��B�ڂ�����<a href="$guide_url">�����K�C�h���C��</a>������񂭂������B);
if(!$secret_mode){ $deletertext .= qq(<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">���[���ᔽ</a>����������A<a href="${base_url}_delete/$kboad">�폜�˗��f����</a>�܂ł��A�����������B<a href="all-deleted$klink.html#M" rel="nofollow" class="red">�폜�ς݋L���̈ꗗ</a>������܂��B); }

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
$doubletext = qq(<div>$doublemark<br$xclose>$doubletext</div>\n);
$zatudanntext = qq(<div>$zatudannmark<br$xclose>$zatudanntext</div>\n);
$allruletext = qq(<div>$allrulemark<br$xclose>$allruletext</div>\n);
$deletertext = qq(<div>$deletermark<br$xclose>$deletertext</div>\n);

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

return($rule_text,$zatudanntext,$doubletext,$ngjuufukuflag,$pefrule_text);

}


1;
