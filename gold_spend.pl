
# �錾
package Mebius::Goldcenter;
use Mebius::Auth;
use Mebius::Jump;
use strict;

#-----------------------------------------------------------
# �V�K���e�̃L�����Z���t�H�[��
#-----------------------------------------------------------
sub form_cancel_newwait{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line,$newwait_flag,$newwait_hour,$disabled,$alert);

# �V�K���e�̑҂����Ԃ��擾
require "${main::int_dir}part_newwaitcheck.pl";
($newwait_flag,$newwait_hour) = main::sum_newwait();

# HTML�������`
$line .= qq(
<h3>�V�K���e�̑҂����Ԃ��Ȃ���</h3>
<ul>
<li>�K�v�ȋ���: <strong class="red">$price{'cancel_newwait'}��</strong> / ���� $main::cgold ��</li>
<li>���݂̑҂����ԁF $newwait_hour</li>
</ul>
<form action="./" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="cancel_newwait"$main::xclose>);

	# ���s�ł��Ȃ����̏ꍇ
	if(!$main::callsave_flag){ $alert = qq(�����̊��ł͎��s�ł��܂���B); }
	# �V�K�҂����Ԃ��Ȃ��ꍇ
	elsif($main::cgold < $price{'cancel_newwait'}){ $alert = qq(�����݂�����܂���B); }
	# ���݂�����Ȃ��ꍇ
	elsif(!$newwait_flag){ $alert = qq(���҂����Ԃ�����܂���B); }
	#�A���[�g���̐��`
	if($alert && $script_mode !~ /TEST/){ $alert = qq(<span class="alert">$alert</span>); $disabled = $main::parts{'disabled'}; }

# ���`
$line .= qq(
<input type="submit" value="���s����"$disabled$main::xclose>
$main::backurl_input
$alert
</div>
</form>
);

# ���^�[��
return($line);

}





#-----------------------------------------------------------
# �V�K���e�̑҂����Ԃ��Ȃ���
#-----------------------------------------------------------
sub cancel_newwait{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($successed);

# ���ݖ������`�F�b�N
&cash_check("REGIST","$price{cancel_newwait}");

# �V�K���e�̑҂����Ԃ��Ȃ��� 
require "${main::int_dir}part_newwaitcheck.pl";
($successed) = main::sum_newwait("UNLINK");

# ���������ꍇ�A���݂������āACookie���Z�b�g����
if($successed == 1 ||  $script_mode =~ /TEST/){
$main::cnew_time = undef;
$main::cgold -= $price{cancel_newwait};
Mebius::set_cookie();
&record_spend("RENEW","�V�K�҂����Ԃ����炵�܂����B");
}

# ���s�����ꍇ�A�G���[��\������
else{
main::error("�V�K���e�̑҂����Ԃ�����܂���B");
}
# �y�[�W�W�����v
Mebius::Jump("","$gold_url?$main::backurl_query_enc#SPEND_GOLD","1","�V�K���e�̑҂����Ԃ����炵�܂����B");

# �I��
exit;

}


#-----------------------------------------------------------
# ���݂̃v���[���g�t�H�[��
#-----------------------------------------------------------
sub form_present_gold{

# �錾
my($type) = @_;
my($line,$value_account,$select_gold,$gave_gold_submit_admin,@piece_of_gold);

# �A���[�g
my($alert,$disabled1) = &cash_check("VIEW",1);

# �������͒l
$value_account = $main::pmfile;
if($main::in{'account'}){ $value_account = $main::in{'account'}; }

#<input type="text" name="present_gold" value="1" size="5"$disabled1$main::xclose>

# ���ݖ����̑I��
@piece_of_gold = (1,2,3,4,5,6,7,8,9,10,20,30);
$select_gold .= qq(<select name="present_gold"$disabled1>);
foreach(@piece_of_gold){
$select_gold .= qq(<option value="$_">$_��</option>\n);
}
$select_gold .= qq(</select>);

# ���݂̎��^�{�^���i�Ǘ��Ґ�p�j
if($main::myadmin_flag >= 1){
$gave_gold_submit_admin = qq(
<input type="submit" name="gave_gold" value="���^">
<span class="alert">*���^�͊Ǘ��Ґ�p�ł��B���[�U�[�ւ̂���ȂǂɎg���Ă��������B�����̋��݂͌���܂��񂪁A�����ʂȔz�z��A�����̃A�J�E���g�ւ̔z�z�͂�߂܂��傤�B</span>
);

}

# HTML�������`
#$line .= qq(
#<h3 id="PRESENT_GOLD">���݂��v���[���g����</h3>
#<span style="color:#f00;">*���̋@�\\�͒�~���ł��B�i<a href="http://mb2.jp/_auth/aurayuma/d-21">�ڍ�</a>�j</span>
#<ul>
#<li>���̐l(�̃A�J�E���g)�ɁA���݂��v���[���g�ł��܂��B���݂��͂��ƁA����̃}�C�y�[�W�ɂ��m�点���\\������܂��B</li>
#<li>����̃A�J�E���g����������Ȃ��ꍇ�� <a href="${main::auth_url}aview-newac-1.html" class="blank" target="_blank">�����o�[����</a> ���Ă��������B</li>
#<li>�K�v�ȋ���: <strong class="red">�C��</strong> / ���� $main::cgold ��</li>
#</ul>
#<form action="./" method="post"$main::sikibetu>
#<div>
#<input type="hidden" name="mode" value="present_gold"$main::xclose>
#<input type="text" name="account" value="$value_account" size="12"$disabled1$main::xclose> �����
#$select_gold
#<input type="submit" name="chaise_gold" value="���v���[���g"$disabled1$main::xclose>
#$gave_gold_submit_admin
#$main::backurl_input
#<span class="guide">���A�J�E���g���𔼊p�p�����ŁA�����𔼊p�����œ��͂��Ă��������B</span>
#$alert
#</div>
#</form>
#);



# ���^�[��
return($line);



}

#-----------------------------------------------------------
# ���݂��v���[���g / ���^ ( �Ǘ��҃`�F�b�N������ bas_gold.pl �ɂ��� )
#-----------------------------------------------------------
sub present_gold{

# �錾
my($type,$account,$present_gold) = @_;
my($script_mode,$gold_url,$title,$gave_gold_type) = &init();
my($message,$message2,$myhandle,%option_renew,%option,$maxgive_perday);

# �P���̋��݃v���[���g�̏����
if($main::myadmin_flag){ $maxgive_perday = 1000; }
else{ $maxgive_perday = 50; }

# �A�J�E���g�f�[�^���擾
#(%option) = Mebius::Auth::Optionfile("",$main::pmfile,%option);
(%option) = Mebius::Auth::File("Option",$main::pmfile);

# ���ɂ����X�V����Ă���ꍇ�́A���݃v���[���g�̏�������Z�b�g����
if($option{'lastpresentgold'} ne "$main::thisyear-$main::thismonthf-$main::todayf"){ $option{'todaypresentgold'} = 0; }

# �P���̏�����z���Ă���ꍇ
if($option{'todaypresentgold'} >= $maxgive_perday){ main::error("�����͂������݂��v���[���g�ł��܂��� ($option{'todaypresentgold'}��/$maxgive_perday��) �B�����܂ł��҂����������B"); }

# ���z���`
if($present_gold =~ /^-/){ main::error("���݂�D���Ȃ�ĂƂ�ł��Ȃ����Ƃł��B"); }
$present_gold =~ s/\D//g;
$present_gold = int($present_gold);
if($present_gold eq ""){ main::error("���z���w�肵�Ă��������B"); }
if($present_gold > 50){ main::error("�������������܂��B"); }
if($present_gold <= 0){ main::error("�������w�肵�Ă��������B"); }

# �����`�F�b�N
lc $account;
if($account =~ /[^a-z0-9]/){ main::error("����̃A�J�E���g���͔��p�p�����Ŏw�肵�Ă��������B( 0-9 a-z )"); }
$account =~ s/[^a-z0-9]//g;
if($account eq ""){ main::error("����̃A�J�E���g���w�肵�Ă��������B"); }
if($account eq $main::pmfile && !$main::alocal_mode){ main::error("�����ɂ̓v���[���g�ł��܂���B"); }

# ���z���`�F�b�N�A�A�N�Z�X����
if($type =~ /PRESENT/){ &cash_check("REGIST",$present_gold); }

# ����̃A�J�E���g�f�[�^���X�V
($myhandle) = &get_handle();
if($type =~ /PRESENT/){ $message2 = qq($myhandle ���񂩂���݂̃v���[���g������܂���($present_gold��)�B); }
elsif($type =~ /GAVE/){ $message2 = qq($myhandle ������݂̎��^������܂���($present_gold��)�B); }
main::call_savedata($account,"ACCOUNT RENEW MESSAGE","","$present_gold<>$message2<>");

# ���z���x����
if($type =~ /PRESENT/){ $main::cgold -= $present_gold; }

# �����̃N�b�L�[���Z�b�g
Mebius::set_cookie();

# ���b�Z�[�W���`
if($type =~ /PRESENT/){ $message = qq(<a href="${main::auth_url}$account/">$account</a> ����ɋ��݂� $present_gold���v���[���g���܂����B); }
elsif($type =~ /GAVE/){ $message = qq(<a href="${main::auth_url}$account/">$account</a> ����ɋ��݂� $present_gold�����^���܂����B); }

# �A�J�E���g�̋��ݏ�������X�V
#$option_renew{'lastpresentgold'} = "$main::thisyear-$main::thismonthf-$main::todayf";
#$option_renew{'todaypresentgold'} = $option{'todaypresentgold'} + $present_gold;
#Mebius::Auth::Optionfile("Renew",$main::pmfile,%option_renew);
$option_renew{'lastpresentgold'} = "$main::thisyear-$main::thismonthf-$main::todayf";
$option_renew{'todaypresentgold'} = $option{'todaypresentgold'} + $present_gold;
Mebius::Auth::File("Renew Option",$main::pmfile,\%option_renew);

# ���݂̎g�p�L�^
&record_spend("RENEW","$message");

# �y�[�W�W�����v
Mebius::Jump("","$gold_url?$main::backurl_query_enc#PRESENT_GOLD","3","$message");

# �I��
exit;

}


#-----------------------------------------------------------
# �q�����݃t�H�[��
#-----------------------------------------------------------
sub form_gyamble1{

# �錾
my($type,$getgold,$chaise_gold,$viewplus_html) = @_;
my($script_mode,$gold_url,$title) = &init();
my($line,$doubleup_input,$winlose_renew_line,$winlose_handle,$top_winlose,$wingold_all,$losegold_all);
my($winlose_line,$h3,$domain_links);

# �A���[�g���擾
my($alert,$disabled1) = &cash_check("VIEW",1);
my($alert,$disabled2) = &cash_check("VIEW",3);
my($alert,$disabled3) = &cash_check("VIEW",5);

	# �_�u���A�b�v
	if($type =~ /Doubleup/){
	$doubleup_input = qq(
	<input type="submit" name="chaise_gold" value="�l������ ( $getgold�� )���_�u���A�b�v����">
	);
	}

	# ������O�ꖇ���t�@�C�����J��
	if($type =~ /Winlose-get/){
	open($winlose_handle,"${main::int_dir}_goldcenter/winlose_goldcenter.log");
	flock($winlose_handle,1);
	($top_winlose) = <$winlose_handle>; chomp $top_winlose;
	($wingold_all,$losegold_all) = split(/<>/,$top_winlose);
	close($winlose_handle);
	}

	# ������O�ꖇ�����X�V����
	if($type =~ /Winlose-renew/){
		if($type =~ /Result-win/){ $wingold_all += $chaise_gold; }
		else{ $losegold_all += $chaise_gold; }
	$winlose_renew_line = qq($wingold_all<>$losegold_all<>\n);
	Mebius::Fileout("","${main::int_dir}_goldcenter/winlose_goldcenter.log",$winlose_renew_line);
	}

	# ������O��\���𐮌`
	if($type =~ /Winlose-get/){
	$winlose_line = qq(<h3>�S���̐���</h3>
	<ul>
	<li>�����F <strong class="red">$wingold_all</strong> ��</li>
	<li>�����F <strong class="blue">$losegold_all</strong> ��</li>
	</ul>
	);
	}

	# H3 �̃����N��`
	if($type =~ /Page-me/){ $h3 = qq(���݂�q����); }
	else{ $h3 = qq(<a href="gyamble1.html">���݂�q����</a>); }

# HTML�������`
$line .= qq(
$viewplus_html
<h3 id="GYAMBLE1">$h3</h3>
�����̊m���ŁA�|����(����)��{�ɏo���܂��B
<ul>
<li>�K�v�ȋ���: <strong class="red">1�`10��</strong> / ���� $main::cgold ��</li>
</ul>
<form action="./gyamble1.html" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="gyamble1"$main::xclose>
<input type="submit" name="chaise_gold" value="1���q��"$disabled1$main::xclose>
<input type="submit" name="chaise_gold" value="3���q��"$disabled2$main::xclose>
<input type="submit" name="chaise_gold" value="5���q��"$disabled3$main::xclose>
$doubleup_input
$main::backurl_input
$alert
</div>
</form>
$winlose_line
);

	# �y�[�W�Ƃ��ĕ\������ꍇ
	if($type =~ /Indexview/){
	
		($domain_links) = Mebius::Domainlinks("","$main::server_domain","_gold/gyamble1.html");

		$main::head_link4 = qq( &gt; �q������ );
		my $print = qq(<h1>�q������</h1><a href="$gold_url">$title�ɖ߂�</a> �@/�@ 	$domain_links$line);
		Mebius::Template::gzip_and_print_all({},$print);
	}

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# ���݂�q����
#-----------------------------------------------------------
sub gyamble1{

# �錾
my($type,$in_chaise_gold) = @_;
my($script_mode,$gold_url,$title) = &init();
my($chaise_gold,$getgold,$message,$result,$doubleup_file,$i_double_up,@doubleup_line,$doubleup_gold,$rand);
my($filehandle1,$i_doubleup,$retry_form,$viewplus_html);

# GET���M���֎~
if(!$main::postflag){ main::error("GET���M�͏o���܂���B"); }


	# �_�u���A�b�v�t�@�C�����`
	$doubleup_file = "${main::int_dir}_goldcenter/doubleup.log";

		# �_�u���A�b�v�t�@�C�����J���Ċ|�������擾
		open($filehandle1,"<$doubleup_file");
			while(<$filehandle1>){
			$i_doubleup++;
			chomp;
			my($hitflag);
			my($lastgold2,$account2,$k_accesses2,$time2) = split(/<>/,$_);
				if($account2 && $account2 eq $main::pmfile){ $hitflag = 1; }
				if($k_accesses2 && $k_accesses2 eq $main::device{'k_accesses'}){ $hitflag = 1; }
				if($hitflag && $lastgold2){ $doubleup_gold = $lastgold2; }
				if(!$hitflag){ push(@doubleup_line,"$lastgold2<>$account2<>$k_accesses2<>$time2<>\n"); }
				if($i_doubleup >= 50){ next; }
			}
		close($filehandle1);

	# �_�u���A�b�v�̏ꍇ
	if($in_chaise_gold =~ /�_�u���A�b�v/){
	$chaise_gold = $doubleup_gold;
	}

	# �|������I������ꍇ
	else{
		if($in_chaise_gold =~ /1��/){ $chaise_gold = 1; }
		elsif($in_chaise_gold =~ /3��/){ $chaise_gold = 3; }
		elsif($in_chaise_gold =~ /5��/){ $chaise_gold = 5; }

	# �A�����M���֎~
	#main::redun("Goldcenter","1");

	}

	# �|�������`�F�b�N�A�A�N�Z�X����
	&cash_check("REGIST",$chaise_gold);

# �܂��͊|�������x����
$main::cgold -= $chaise_gold;

# �����蔻��
$rand = int rand(100);

# ������̏ꍇ
	if($rand >= 50){
	$getgold = $chaise_gold*2;
	$main::cgold += $getgold;
	$message = qq(����ł��I ���� <strong class="red">$getgold</strong> ���������߂���܂����B ( <a href="$gold_url">���߂�</a> ) );
	if($chaise_gold >= 50){ &record_spend("RENEW","���� $chaise_gold���𓖂Ă܂����B "); }
	$result = "win";
	$main::css_text .= qq(ul.result{background:#fdd;padding:1em 2.5em;width:50%;});	
	}

	# �O��̏ꍇ
	else{
	$message = qq(�O��ł��B ���� <strong class="blue">$chaise_gold</strong> ���͖v������܂����B( <a href="$gold_url">���߂�</a> ) );
	$result = "lose";
	$main::css_text .= qq(ul.result{background:#ddf;padding:1em 2.5em;width:50%;});	
}



# �N�b�L�[���Z�b�g
Mebius::set_cookie();

# �_�u���A�b�v�t�@�C���ɒǉ�����s
if($result eq "win"){
unshift(@doubleup_line,"$getgold<>$main::pmfile<>$main::device{'k_accesses'}<>$main::time<>\n");
}

# �_�u���A�b�v�L�^�t�@�C�����X�V
Mebius::Fileout("Can-Zero",$doubleup_file,@doubleup_line);

# <h3 class="result">����</h3>
# �����p��HTML
$viewplus_html = qq(
<ul class="result">
<li>$message</li>
<li>���� �F $rand\p / 50p </li>
</ul>
);

	# �������ꍇ�A�_�u���A�b�v�̃`�����X��
	if($result eq "win"){
	($retry_form) = &form_gyamble1("Doubleup Winlose-get Winlose-renew Result-win Indexview Page-me","$getgold",$chaise_gold,$viewplus_html);
	}
	else{
	($retry_form) = &form_gyamble1("Winlose-get Winlose-renew Result-lose Indexview Page-me","",$chaise_gold,$viewplus_html);
	}


# �I��
exit;

}



1;
