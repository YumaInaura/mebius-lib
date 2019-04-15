
use strict;
use Mebius::History;
use Mebius::Time;
use Mebius::AuthAccount;
#use Mebius::AuthServerMove;
use Mebius::Query;
package main;
use Mebius::Export;

#-------------------------------------------------
# �ҏW�����s - �}�C�A�J�E���g
#-------------------------------------------------
sub auth_editprof{

# �Ǐ���
my($change_name_flag,$redirect_flag,%account);
my($enctrip,%renew,$myurl_title,$get_urltitle_flag,$error_flag_sendmail,$cermail_message);
our($file) = undef;
our($e_com,$fook_error,$head_link3,$i_trip,%in,$postflag,$alocal_mode,$auth_domain);
our($int_dir,$jump_sec,$jump_url,$idcheck,$myadmin_flag,$server_domain);
our($pmfile,$sendcermail_flag,$date,$pmname,$auth_url,%ch);

	# ���[���L�ڂ̉����p�t�q�k����A�z�M���[������������
	if($in{'type'} eq "cancel_mail"){
		require "${main::int_dir}part_cermail.pl";
		Mebius::Email::CancelMailSNSAccount(undef,$main::in{'account'},$main::in{'char'});
	}

# �A�N�Z�X����
&axscheck("NOLOCK");

	# SNS��~��
	if($main::stop_mode =~ /SNS/){
		main::error("���݁ASNS�͒�~���̂��߁A�v���t�B�[���͍X�V�ł��܂���B");
	}

	# �t�@�C����`
	if($in{'account'} && $myadmin_flag){ $file = $in{'account'}; }
	else{ $file = $pmfile; }
$file =~ s/[^0-9a-z]//;
	if($file eq ""){ $e_com .= qq(���v���t�B�[����ҏW����ɂ́A�A�J�E���g�Ƀ��O�C�����Ă��������B<br>); }

# �^�C�g���Ȃǒ�`
$head_link3 = "&gt; �ҏW";

	# �h���C���u���b�N
	if(!$postflag){ $e_com .= qq(�f�d�s���M�͏o���܂���B); }
	if("http://$server_domain/" ne $auth_url && !$alocal_mode){ main::error("�T�[�o�[���Ⴂ�܂��B"); }

# �A�J�E���g���J��
(%account) = Mebius::Auth::File("Hash",$file);

# ID�A�g���b�v�t�^
($enctrip) = &trip($in{'name'});

# �e��`�F�b�N
require "${int_dir}regist_allcheck.pl";
my($i_handle) = shift_jis(Mebius::Regist::name_check($in{'name'}));
($in{'prof'}) = &all_check("Edit-profile",$in{'prof'});

	# �������߂t�q�k������ ( URL���e���ς�����ꍇ�̂݁A�`�F�b�N���� )
	if($in{'myurl'} eq "http://"){ $in{'myurl'} = ""; }
	if($in{'myurl'}){
			if($in{'myurl'} =~ /$auth_url/){ $e_com .= qq(��SNS���̂t�q�k ( $in{'myurl'} ) �͎g���܂���B�f��������I��ł��������B<br>); }
			elsif($account{'myurl'} ne $in{'myurl'}){
				&url_check("Status Grammar Limited",$in{'myurl'});
				#$get_urltitle_flag = 1;
			}
	}


# �ҏW���e�̏���
my $length = int(length($in{'prof'}));
if($length > 5000*2){ $e_com .= qq(���v���t�B�[�����������܂��B( $length���� / 5000���� )<br>); }
if($in{'prof'} =~ /�O��/ && $in{'prof'} =~ /([0-9]{8,})/){ $e_com .= qq(���O���v���t�B�[���̂h�c���������܂Ȃ��ł��������B<br>); }
if($main::myaccount{'key'} eq "2" && $in{'prof'} ne ""){ $e_com .= qq(���A�J�E���g�����b�N����Ă���ꍇ�A�v���t�B�[�������S�ɍ폜���Ȃ���΁A�ݒ�ύX�ł��܂���B<br>); }

# ���_�C���N�g����ꍇ
#if($account{'orireki'} ne $in{'pporireki'}){ $redirect_flag = 1; }

	# �M���ύX���`�F�b�N
	if($i_handle ne $account{'name'}){ $change_name_flag = 1; }

	# �����̃A�J�E���g�ȊO�͕ҏW�ł��Ȃ�
	if(!$account{'myprof_flag'} && !$myadmin_flag){ main::error("�����̃A�J�E���g�ȊO�ҏW�ł��܂���B"); }

	# �A�J�E���g���C�p�X����v���Ȃ��ꍇ�G���[
	if(!$idcheck){ $e_com .= qq("���ҏW����ɂ̓��O�C�����Ă��������B<br>"); }

	# ���e��ݒ�l�̉����`�F�b�N
	$in{'ppocomment'} =~ s/\D//g;
	if(length($in{'ppocomment'}) >= 4){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	elsif($in{'ppocomment'} > 4){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }

	$in{'ppodiary'} =~ s/\D//g;
	if(length($in{'ppodiary'}) >= 2){ $e_com .= qq("���ݒ�l���ςł�<br>�B"); }
	elsif($in{'ppodiary'} > 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }

	$in{'ppobbs'} =~ s/\D//g;
	if(length($in{'ppobbs'}) >= 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	elsif($in{'ppobbs'} > 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }

	$in{'pposdiary'} =~ s/\D//g;
	if(length($in{'pposdiary'}) >= 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	elsif($in{'pposdiary'} > 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	if($account{'level'} < 1){ $in{'pposdiary'} = ""; };

	$in{'pposbbs'} =~ s/\D//g;
	if(length($in{'pposbbs'}) >= 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	elsif($in{'pposbbs'} > 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	if($account{'level'} < 1){ $in{'pposbbs'} = ""; };

	$in{'pporireki'} =~ s/\D//g;
	if(length($in{'pporireki'}) >= 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
	elsif($in{'pporireki'} > 2){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }


	$in{'ppcolor2'} =~ s/\W//g;
	if(length($in{'ppcolor2'}) > 3){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }



	# ���[���p�X�������ꍇ�i���F�؂̏ꍇ�j�A���m�F��ԂƂ��ă��[���A�h���X�݂̂��L�^����j
	# ���t�ɁA���ɔF�؍ς݂̏ꍇ�́A���[���A�h���X�����͂���Ă��f�[�^��ύX���Ȃ��i�m�F���[��������������ύX�\�j
	if($account{'mlpass'} eq ""){ $renew{'email'} = $in{'email'}; }

	# ���[�U�[�̓��͓��e����A���[���A�h���X�A���[���p�X���폜����
	if($in{'reset_email'}){ $renew{'email'} = ""; $renew{'mlpass'} = ""; }

# ���t�@�C���ύX���e�̒�` ( ����`�l�����Ȃ� )

	# �v���t�B�[��
	if($ch{'prof'}){
		if($in{'prof'} eq ""){ $renew{'prof'} = ""; }
		else{ $renew{'prof'} = $in{'prof'}; }
	}

	# �M��
	if($ch{'name'}){
		$renew{'name'} = $i_handle;
		$renew{'mtrip'} = $i_trip;
		$renew{'enctrip'} = $enctrip;
		if($renew{'mtrip'} eq ""){ $renew{'mtrip'} = ""; }
		if($enctrip eq ""){ $renew{'enctrip'} = ""; }
	}

	# �}�C�t�q�k
	if($ch{'myurl'}){
		if($in{'myurl'} eq ""){ $renew{'myurl'} = ""; }
		else{ $renew{'myurl'} = $in{'myurl'}; }
	}

	# �}�C�t�q�k�̃^�C�g��
	if($ch{'myurltitle'}){
			my($myurl_title) = &subject_check("Empty",$in{'myurltitle'});
			if($in{'myurltitle'} eq ""){ $renew{'myurltitle'} = ""; }
			else{ $renew{'myurltitle'} = $myurl_title; }
	}

	# �����F
	if($ch{'ppcolor2'}){
		$in{'ppcolor2'} =~ s/\W//g;
		if(length($in{'ppcolor2'}) > 3){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
		$renew{'color2'} = $in{'ppcolor2'};
		($renew{'color2'}) = Mebius::Regist::color_check(undef,$renew{'color2'});
	}

	# �ѐF
	if($ch{'ppcolor1'}){
		$in{'ppcolor1'} =~ s/\W//g;
		if(length($in{'ppcolor1'}) > 3){ $e_com .= qq("���ݒ�l���ςł��B<br>"); }
		$renew{'color1'} = $in{'ppcolor1'};
		#($renew{'color1'}) = Mebius::Regist::color_check(undef,$renew{'color1'});
	}

	# SNS�̍s������
	if($ch{'ohistory'}){
		if($in{'ohistory'} =~ /^(use-open|use-close|not-use)$/){ $renew{'ohistory'} = $in{'ohistory'}; }
	}

	# �֘A�����N
	if($ch{'okr'}){
		if($in{'okr'} =~ /^(use-open|use-close|not-use)$/){ $renew{'okr'} = $in{'okr'}; }
		#if($renew{'okr'} ne $account{'okr'} && $renew{'okr'} eq "not-use"){ &access_log("SNS-Notkr","�֘A�����N���I�t�ɁF $file"); }
	}

	# �L�̎󂯎��
	if($ch{'allow_vote'}){
		if($in{'allow_vote'} eq "not-use"){ $renew{'allow_vote'} = "not-use"; }
		else{ $renew{'allow_vote'} = "use-open"; }
	}


	# ���a����
	if($main::ch{'birthday_year'} || $main::ch{'birthday_month'} || $main::ch{'birthday_day'}){

			# �����`�F�b�N
			if($main::in{'birthday_year'} =~ /\D/ || $main::in{'birthday_month'} =~ /\D/ || $main::in{'birthday_day'} =~ /\D/){
				main::error("�a�����̔N�����͐����Ŏw�肵�Ă��������B");
			}

			# �����͂̒l������ꍇ
			#if($main::in{'birthday_year'} eq "" || $main::in{'birthday_month'} eq "" || $main::in{'birthday_day'} eq ""){
			#	$main::e_com .= qq(���a��������͂���ꍇ�́A�N/��/���̂��ׂĂ��w�肵�Ă��������B<br>);
			#}

			# �Ǐ���
			my($error_text);

			# �N
			if($account{'birthday_year'} && !$main::myadmin_flag){ $renew{'birthday_year'} = $account{'birthday_year'}; }
			else{ $renew{'birthday_year'} = $main::in{'birthday_year'}; }
			# ��
			if($account{'birthday_month'} && !$main::myadmin_flag){ $renew{'birthday_month'} = $account{'birthday_month'}; }
			else{ $renew{'birthday_month'} = $main::in{'birthday_month'}; }
			# ��
			if($account{'birthday_day'} && !$main::myadmin_flag){ $renew{'birthday_day'} = $account{'birthday_day'}; }
			else{ $renew{'birthday_day'} = $main::in{'birthday_day'}; }

				# �����肦�Ȃ��N���̓G���[��
				if($renew{'birthday_year'} && $renew{'birthday_year'} > $main::thisyear){ main::error("�����ɐ��܂ꂽ�̂ł����H"); }
				if($renew{'birthday_year'} && $renew{'birthday_year'} < $main::thisyear - 150){ main::error("����Ȃɂ������Ȃ̂ł����H"); }

				# ���͂��߂Ċe�l��ݒ肷��ꍇ�A�x����\������
				if($main::in{'birthday_year'} && !$account{'birthday_year'}
				|| $main::in{'birthday_month'} && !$account{'birthday_month'}
				|| $main::in{'birthday_day'} && !$account{'birthday_day'}){
					$main::a_com .= qq(<span style="color:#f00;">���a�����͂����ǐݒ肷��ƁA���Ƃ���ύX�ł��܂��񂪁A��낵���ł����H<br$main::xclose>);
					$main::a_com .= qq(�@�@�N����U���Ă̓o�^�͂������������B�i�ݒ肵�����Ȃ��ꍇ�́A�󗓂̂܂܂ɂ��Ă����Ă��������j<br$main::xclose>���U�̓o�^���������ꍇ�A<strong>�A�J�E���g���b�N�◘�p�֎~</strong>�Ȃǂ̏��u����点�Ă��������ꍇ������܂��B</span><br$main::xclose>);
				}

				# �O���j�b�W�W�������擾
				if($renew{'birthday_year'}){
					($renew{'birthday_time'},$error_text) = Mebius::TimeLocal(undef,$renew{'birthday_year'},$renew{'birthday_month'},$renew{'birthday_day'});
				}
				else{
					$renew{'birthday_time'} = "";
				}

			# �G���[
			if($error_text){ main::error($error_text); }

	}

	# ���a�������J�̐ݒ�
	if($main::ch{'birthday_concept_open'}){
			if($main::in{'birthday_concept_open'} =~ /^(Not-open|Friend-open)$/){
				$renew{'birthday_concept'} .= qq( $main::in{'birthday_concept_open'});
			}
	}

	# �� ���b�Z�[�W�@�\�̋���
	if($main::ch{'allow_message'}){


			# �Ǘ��҂����p�֎~�ݒ�����Ă���ꍇ�A�ύX�ł��Ȃ��悤��
			if($account{'allow_message'} =~ /^(Deny-use)$/ && !$main::myadmin_flag){

			}

			# �X�V���e���`
			elsif($main::in{'allow_message'} =~ /^(Use|Not-use|Friend-only|Deny-use)$/){
				$renew{'allow_message'} = $main::in{'allow_message'};
			}

	}


	#�� ���[���̎�M�ݒ�
	if($main::ch{'catch_mail_message'}){
			if($main::in{'catch_mail_message'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_message'} = $main::in{'catch_mail_message'};
			}
	}
	if($main::ch{'catch_mail_resdiary'}){
			if($main::in{'catch_mail_resdiary'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_resdiary'} = $main::in{'catch_mail_resdiary'};
			}
	}
	if($main::ch{'catch_mail_comment'}){
			if($main::in{'catch_mail_comment'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_comment'} = $main::in{'catch_mail_comment'};
			}
	}
	if($main::ch{'catch_mail_etc'}){
			if($main::in{'catch_mail_etc'} =~ /^(Catch|Not-catch)$/){
				$renew{'catch_mail_etc'} = $main::in{'catch_mail_etc'};
			}
	}

	# ���O�C�����ԕ\���̋��ݒ�
	if($main::ch{'allow_view_last_access'}){
			if($main::in{'allow_view_last_access'} =~ /^(Open|Login-user-only|Friend-only|Not-open)$/){
				$renew{'allow_view_last_access'} = $main::in{'allow_view_last_access'};
			}
	}

	# �����ˁI�̎�M�ݒ�
	if($main::ch{'allow_crap_diary'}){
			if($main::in{'allow_crap_diary'} =~ /^(Allow|Deny)$/){
				$renew{'allow_crap_diary'} = $main::in{'allow_crap_diary'};
			}
	}

	# �t�@�C���ύX���e�̒�`�i�ӂ�����`�ɂ͂Ȃ�Ȃ��l�j
	if($ch{'ppocomment'}){ $renew{'ocomment'} = $in{'ppocomment'}; }
	if($ch{'ppodiary'}){ $renew{'odiary'} = $in{'ppodiary'}; }
	if($ch{'pposdiary'}){ $renew{'osdiary'} = $in{'pposdiary'}; }
	if($ch{'pporireki'}){ $renew{'orireki'} = $in{'pporireki'}; }

	# �����̃v���t�B�[���ύX�̏ꍇ
	if($account{'myprof_flag'}){
		$renew{'edittime'} = $main::time;
	}

	# �Ǘ��҂����[�U�[�t�@�C����ύX�����ꍇ
	if($myadmin_flag && !$account{'myprof_flag'}){
	
		# �v���t�B�[���̏C��
		#if($account{'prof'} && $account{'prof'} ne $renew{'prof'}){
		#	$renew{'prof'} = qq(<em>�Ǘ��� ($pmname - $pmfile) �ɂ��C�� ($date)</em><br>$renew{'prof'});
		#}
	}


# �G���[�ƃv���r���[
&error_view("AERROR Target","auth_editprof_error");

	# ���[���A�h���X���F�؂���Ă��āA�G���[���Ȃ��ҏW���s����ꍇ�A�m�F�p���[���A�h���X��z�M����
	if($main::in{'email'} && $account{'myprof_flag'}){
		require "${main::int_dir}part_cermail.pl";
		($error_flag_sendmail,$cermail_message) = Mebius::Email::SendCermail("SNS-account",$main::in{'email'},$main::pmfile);
			if($error_flag_sendmail){ $main::e_com .= qq(��$error_flag_sendmail<br$main::xclose>); }
			if($cermail_message){ $cermail_message = qq(<hr$main::xclose>$cermail_message); }
	}

	# �v���t�B�[���̕ύX��F��
	if(defined($renew{'prof'}) && $account{'prof'} ne $renew{'prof'}){
		$renew{'last_profile_edit_time'} = $main::time;
	}

# �G���[�ƃv���r���[
&error_view("AERROR Target","auth_editprof_error");

# �ҏW���s
Mebius::Auth::File("Renew Option",$file,\%renew);

# �I�v�V�����t�@�C�����X�V ( �����炭�ŏI�����������`���A�z�X�g���Ȃǂ��X�V���Ă��� )
#Mebius::Auth::Optionfile("Renew",$file);

# �M�������̍X�V
&auth_renew_namefile($file);

	# �M����ύX�����ꍇ
	if($change_name_flag){
		Mebius::Auth::AccountListFile("Renew Edit-account Normal-file",$file,$i_handle);
		Mebius::Auth::AccountListFile("Renew Edit-account Search-file",$file,$i_handle);
	}

	# �Ǘ��ҕҏW�̏ꍇ�ȂǁA���Α��T�[�o�[�փ��_�C���N�g�i�P�j
	if($redirect_flag && !$alocal_mode){ Mebius::Redirect("","http://aurasoul.mb2.jp/_auth/?mode=editprof&type=get&pporireki=$in{'pporireki'}&account=$in{'account'}");
	}

	# ���[���z�M�����Ȃ������ꍇ�̓��_�C���N�g
	if($in{'email'}){ }
	else{
		$jump_url = "${main::auth_url}$file/#EDIT";
		Mebius::Redirect("",$jump_url);
	}

# HTML
my $print = <<"EOM";
�ҏW���܂����B(<a href="${main::auth_url}$file/#EDIT">���߂�</a>�j<br>
$cermail_message
EOM

Mebius::Template::gzip_and_print_all({ BCL => [$head_link3] },$print);

# �����I��
exit;

}


#-----------------------------------------------------------
# �v���r���[�ƃG���[
#-----------------------------------------------------------
sub auth_editprof_error{

# �錾
my($error) = @_;
my($myform,$error_line);
our($lockflag,%in,$int_dir,$file);

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }

# �G���[�\��
if($error){
$error_line .= qq(
<h2 id="ERROR">�G���[</h2>
<div class="error">$error</div>
);
}

$error_line = qq(
<h1>�ҏW�t�H�[��</h1>
$error_line
<h2 id="PREV">�v���r���[</h2>
<div class="prev">$in{'prof'}</div>
$myform
);

# �}�C�t�H�[������荞��
require "${int_dir}auth_myform.pl";
if($in{'detail'}){ ($myform) = &auth_myform("Detail",$file,$error_line); }
else{ ($myform) = &auth_myform("",$file,$error_line); }

Mebius::Template::gzip_and_print_all({},$myform);


exit;

}

#-----------------------------------------------------------
# �M�������t�@�C���̍X�V
#-----------------------------------------------------------
sub auth_renew_namefile{

# �Ǐ���
my($file) = @_;
my($line,$flag,$i,$name_handler);
our($int_dir,%in);

# �t�@�C����`
$file =~ s/[^0-9a-z]//;
if($file eq ""){ return; }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

my $file = "${account_directory}${file}_name.cgi";

# �t�@�C�����J��
open($name_handler,"<",$file);
	while(<$name_handler>){
		$i++;
		if($i > 5){ last; }
		chomp;
		my($name) = split(/<>/);
		if($name eq $in{'name'}){ $flag = 1; }
		$line .= qq($name<>\n);
	}
close($name_handler);

if(!$flag){ $line = qq($in{'name'}<>\n) . $line; }

# �t�@�C������������
Mebius::Fileout("",$file,$line);

}


#-------------------------------------------------
# �ҏW�����s (�Ǘ��җp)
#-------------------------------------------------
sub auth_baseedit{

# �Ǐ���
my($basic_init) = Mebius::basic_init();
my($line,$bkline,$max_bkup,$bki,%account,%renew);
our($myadmin_flag,$auth_domain,$idcheck,%in);

# �Ǘ��҂̂�
if($main::myadmin_flag < 5){ main::error("�s���ȏ����ł��B"); }

# �A�N�Z�X����
main::axscheck("");

# �A�J�E���g������
my $account = $main::in{'account'};
if(Mebius::Auth::AccountName(undef,$account)){ main::error("�l��ݒ肵�Ă��������B"); }


# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �f�B���N�g���쐬
Mebius::Mkdir("",$account_directory);

# �^�C�g���Ȃǒ�`
my $head_link3 = "&gt; ����ҏW";

	# �A�J�E���g�t�@�C�����J��
	(%account) = Mebius::Auth::File("Not-file-check",$account); 

# �A�J�E���g���C�p�X����v���Ȃ��ꍇ�G���[
if($myadmin_flag < 5){ &error("�ҏW����ɂ̓��O�C�����Ă��������B"); }

	# �A�J�E���g��~�̏ꍇ�A�R�����g�ݒ��ύX
	if($in{'ppkey'} eq "0" || $in{'ppkey'} eq "2"){
		$renew{'obbs'} = "0";
		$renew{'odiary'} = "0";
		$renew{'ocomment'} = "0";
	}

	# �ύX���e�̒�`
	if($in{'ppkey'} ne ""){
		$renew{'key'} = $in{'ppkey'};
		$renew{'key'} =~ s/\D//g;
	}

	if($in{'pplevel'} ne ""){
		$renew{'level'} = $in{'pplevel'};
		$renew{'level'} =~ s/\D//g;
	}

	if($in{'pplevel2'} ne ""){
		$renew{'level2'} = $in{'pplevel2'};
		$renew{'level2'} =~ s/\D//g;
	}

	if($in{'ppadmin'} ne ""){
		$renew{'admin'} = $in{'ppadmin'};
		$renew{'admin'} =~ s/\D//g;
	}

	if($in{'ppsurl'} ne ""){
		$renew{'surl'} = $in{'ppsurl'};
	}

	if($in{'ppchat'} ne ""){
	$renew{'chat'} = $in{'ppchat'};
			$renew{'chat'} =~ s/\D//g;
	}

	if($in{'ppblocktime'} ne ""){
		$renew{'blocktime'} = $in{'ppblocktime'};
		$renew{'blocktime'} =~ s/\D//g;
	}

	# ����
	if($in{'ppblocktime'} eq "none"){
		$renew{'blocktime'} = "";
		$renew{'key'} = 1;
	}

	# ������
	if($in{'ppblocktime'} eq "forever"){
		$renew{'key'} = 2;
		$renew{'blocktime'} = "";
	}

$renew{'reason'} = $in{'ppreason'};
$renew{'reason'} =~ s/\D//g;
$renew{'adlasttime'} = time;


	# �u���b�N����������ꍇ�́A�����I�ɃA�J�E���g���b�N
	if($in{'ppblocktime'} > time){ $renew{'key'} = 2; }

	# �A�J�E���g���b�N�i�폜�j�̏ꍇ�A�V�K�A�J�E���g�쐬���u���b�N
	if($renew{'key'} eq "0" || $renew{'key'} eq "2"){

	}

	# �A�J�E���g���b�N������
	if($account{'key'} eq "2" && $in{'ppblocktime'} eq ""){
		$renew{'key'} = 1;
	}

	# ���A�J�E���g�L�[���ύX���ꂽ�ꍇ
	if($account{'key'} ne $renew{'key'}){

			# �A�J�E���g���b�N�̉���
			if($renew{'key'} eq "1"){
				$renew{'blocktime'} = "";
				#$renew{'reason'} = "";

				$renew{'-'}{'account_locked_count'} = 1;
					if($account{'last_locked_period'}){ $renew{'last_locked_period'} = ""; }
					if($account{'all_locked_period'}){ $renew{'-'}{'all_locked_period'} = $account{'last_locked_period'}; }

			}

			# �A�J�E���g���b�N
			if($renew{'key'} eq "2"){
				#main::login_history("Deny-make-account",$account,0);
				#&auth_control_account_history("Renew New-history",$account,"Ok!");

				# ����̐V�K�쐬��h�~
				my $make_account_blocktime = $renew{'blocktime'};
					if(!$make_account_blocktime || $in{'ppblocktime'} eq "forever"){ $make_account_blocktime = time + 6*30*24*60*60; }
				Mebius::Login->login_history("Deny-make-account",$account,$make_account_blocktime);

				# ���b�N���ꂽ�񐔂��J�E���g
				$renew{'+'}{'account_locked_count'} = 1;
				$renew{'last_locked_period'} = $renew{'blocktime'} - time;
				$renew{'all_locked_period'} = ($renew{'blocktime'} - time) + $account{'last_locked_period'};
			}

	}

	# �V�����x��
	if($account{'key'} eq "1" && $renew{'reason'} && $account{'allow_next_alert_flag'}){
		$renew{'alert_end_time'} = time + (7*24*60*60);
		$renew{'alert_decide_time'} = time;
		$renew{'+'}{'alert_count'} = 1;
	}

	# �x���̉���
	if($renew{'reason'} eq "" && $account{'alert_flag'}){
		$renew{'alert_end_time'} = "";
		$renew{'-'}{'alert_count'} = 1;
	}

# �A�J�E���g���X�V
Mebius::Auth::File("Renew Admin-renew",$account,\%renew);

	# �����񐔂̋L�^
	if(Mebius::alocal_judge()){
		Mebius::AccessLog(undef,"Auth-edited-admin");
	}

# �ŏI���_�C���N�g��
my $redirect_url_last = "$basic_init->{'auth_url'}${account}/";
	if($in{'backurl'}){ $redirect_url_last = $main::backurl; }

# �T�[�o�[�ԃ��_�C���N�g�����s
#Mebius::Auth::ServerMove("All-servers Direct-redirect Use-all-query Sns-base-edit",$main::server_domain,$redirect_url_last);

Mebius::redirect($redirect_url_last);

# �����I��
exit;

}


#-----------------------------------------------------------
# �������� ( ���݂͔�g�p )
#-----------------------------------------------------------
sub auth_control_account_history{

# �錾
my($type,$account) = @_;
my(undef,undef,$new_text) = @_ if($type =~ /New-history/);
my($i,@renew_line,%data,$file_handler);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = $account_directory;
my $file1 = "${directory1}control_account_history_$account.log";

# �ő�s���`
my $max_line = 50;

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1") && ($data{'f'} = 1);
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$text2,$time2,$date2) = split(/<>/);

			# �C���f�b�N�X�擾
			if($type =~ /Get-index/){
				$data{'index_line'} .= qq(<div>$text2 ( $date2 )</div>);
			}

			# �X�V�p
			if($type =~ /Renew/){

					# �ő�s���ɒB�����ꍇ
					if($i > $max_line){ next; }

				# �s��ǉ�
				push(@renew_line,"$key2<>$text2<>$time2<>$date2<>\n");
			}

	}

close($file_handler);

	# �V�����s��ǉ�
	if($type =~ /New-history/){

		unshift(@renew_line,"<>$new_text<>$main::time<>$main::date<>\n");

	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}

1;
