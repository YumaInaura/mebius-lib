
package main;


#-----------------------------------------------------------
# ���\���A�\�͕\���̉{��
#-----------------------------------------------------------

sub sexvio_check{

my($key) = @_;
my($age);
my($basic_init) = Mebius::basic_init();
my($free);
our $sexvio_text = "";

	# Cookie�̎g���Ȃ��g�тւ̃A�N�Z�X����
	if($k_access && !$cookie){ $free = 1; }
	# Bot�ւ̃A�N�Z�X����
	if($main::device{'bot_flag'}){ $free = 1; }

# CSS��`
$css_text .= qq(.svio_alert{color:#f00;font-size:120%;});

	# ���݂̔N����v�Z
	if($free || Mebius::Admin::admin_mode_judge()){ $age = 20; }
	elsif(!$cage){ $age = 0; }
	else{ $age = $thisyear - $cage; }

	# ���\�����\�͕\��
	if($key eq "3"){
		if(!$age){ &error("���̋L���ɂ́u���I�ȓ��e�v�u�V���b�L���O�ȓ��e���܂܂�܂��B18�ˈȏ�̕���<a href=\"$basic_init->{'main_url'}?mode=settings#EDIT\">�}�C�y�[�W</a>�ŔN��ݒ�����邱�Ƃŉ{���ł��܂��B","401 Unauthorized"); }
		elsif($age < 18){ &error("���̋L���ɂ́u���I�ȓ��e�v�u�V���b�L���O�ȓ��e�v���܂܂�邽�߁A18�˖����̕��͉{���ł��܂���B","401 Unauthorized"); }
		else{ $sexvio_text = qq(���̋L���ɂ́u���I�ȓ��e�v�u�V���b�L���O�ȓ��e�v���܂܂�܂��B); }
	}

	# ���\��
	if($key eq "2"){
		if(!$age){ &error("���̋L���ɂ͐��I�ȓ��e���܂܂�܂��B18�ˈȏ�̕���<a href=\"$basic_init->{'main_url'}?mode=settings#EDIT\">�}�C�y�[�W</a>�ŔN��ݒ�����邱�Ƃŉ{���ł��܂��B","401 Unauthorized"); }
		elsif($age < 18){ &error("���̋L���ɂ͐��I�ȓ��e���܂܂�邽�߁A18�˖����̕��͉{���ł��܂���B","401 Unauthorized"); }
		else{ $sexvio_text = qq(���̋L���ɂ͐��I�ȓ��e���܂܂�܂��B); }
	}

	# �\�͕\��
	if($key eq "1"){
		
		if(!$age){ &error("���̋L���ɂ̓V���b�L���O�ȓ��e���܂܂�܂��B15�ˈȏ�̕���<a href=\"$basic_init->{'main_url'}?mode=settings#EDIT\">�}�C�y�[�W</a>�ŔN��ݒ�����邱�Ƃŉ{���ł��܂��B","401 Unauthorized"); }
		elsif($age < 15){ &error("���̋L���ɂ̓V���b�L���O�ȓ��e���܂܂�邽�߁A15�˖����̕��͉{���ł��܂���B","401 Unauthorized"); }
		else{ $sexvio_text = qq(���̋L���ɂ̓V���b�L���O�ȓ��e���܂܂�܂��B); }
	}

	# �e�L�X�g���`
	if($sexvio_text){
			# �g�є�
			if($kflag){ $sexvio_text = qq(��$sexvio_text�����L���ɖ�肪����ꍇ��<a href="http://aurasoul.mb2.jp/_delete/">�폜�˗��f����</a>�܂ł��m�点���������B<br$xclose>); }
			# PC��
			else{ $sexvio_text = qq(<em class="svio_alert">��$sexvio_text�����L���ɖ�肪����ꍇ�͈ᔽ�񍐂��Ă��������B</em><br$xclose><br$xclose>); }
	}

# �L��������
$noads_mode = 1;

my $return = $sexvio_text;

$return;

}

#-----------------------------------------------------------
# ���\���A�\�͕\���̓��̓`�F�b�N
#-----------------------------------------------------------

sub sexvio_form{

# �Ǐ���
my($age,$checked1,$checked2,$kbr1);
my($basic_init) = Mebius::basic_init();

# �g�тŃN�b�L�[�F�؂ł��Ȃ��ꍇ
my($free);
if($k_access && !$cookie){ $free = 1; }


# ���݂̔N����v�Z
if($free){ $age = 20; }
elsif(!$cage){ $age = 0; }
else{ $age = $thisyear - $cage; }

# �v���r���[�̃`�F�b�N������
if($in{'vio'}){ $checked1 = $checked; }
if($in{'sex'}){ $checked2 = $checked; }

# �g�їp���`
if($kflag){ $kbr1 = qq(<br$xclose>); }
	# �V���b�L���O�ȓ��e
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $category ne "diary"){
	if(!$age){ $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value=""$disabled$xclose> �V���b�L���O�ȓ��e - �\\�́E�C�W���E���X�g�J�b�g�Ȃ� - ���܂ޏꍇ�́A<a href="$basic_init->{'main_url'}?mode=settings#EDIT">�}�C�y�[�W</a>�ŔN��ݒ���ς܂��Ă��������i15�ˈȏ�j�B); }
	elsif($age < 15){  $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value=""$disabled$xclose> 15�˖����̕��́u�V���b�L���O�ȕ\\���v�̃`�F�b�N�������܂���B); }
	else{ $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value="1" $checked1$xclose> ���̋L���ɂ́A�V���b�L���O�ȓ��e���܂܂�܂��i15�˖����̕��ɂ͔���J�ɂȂ�܂��j�B); }
	}
	else{
	if($age >= 15){ $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value="1" $checked1$xclose> ���̋L���ɂ́A�V���b�L���O�ȑ��k�E�c�_���܂܂��̂ŁA15�˖����̕��ɂ͔���J�ɂ��܂��i�C�Ӂj�B); }
	}

	# ���I�ȓ��e
	if($main::bbs{'concept'} =~ /Sousaku-mode/){
	if(!$age){ $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value=""$disabled$xclose> ���I�ȓ��e���܂ޏꍇ�́A<a href="$basic_init->{'main_url'}?mode=settings#EDIT">�}�C�y�[�W</a>�ŔN��ݒ���ς܂��Ă��������i18�ˈȏ�j�B$kbr1); }
	elsif($age < 18){  $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value=""$disabled$xclose> 18�˖����̕��́u���I�ȕ\\���̃`�F�b�N�v���g���܂���B$kbr1); }
	else{ $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value="1" $checked2$xclose> ���̋L���ɂ́A���I�ȓ��e���܂܂�܂��i18�˖����̕��ɂ͔���J�ɂȂ�܂��j�B$kbr1); }
	}
	else{
	if($age >= 18){ $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value="1" $checked2$xclose> ���̋L���ɂ́A���I�ȑ��k�E�c�_���܂܂��̂ŁA18�˖����̕��ɂ͔���J�ɂ��܂��i�C�Ӂj�B$kbr1); }
	}



# PC�Ő��`
if(!$kflag){
$sexcheck = qq(<span class="sexvio">$sexcheck</span>);
$viocheck = qq(<span class="sexvio">$viocheck</span>);
}

}


1;
