
package main;

use Mebius::RegistCheck;
use Mebius::Access;
use Mebius::Encoding;


use Mebius::Export;

use strict;

#-----------------------------------------------------------
# �����X�^�[�g
#-----------------------------------------------------------
sub bbs_regist{

# �錾
our(%in,$no_headerset,$mode,$category,$s_min_msg,$i_nam2);
my($kback_link_tell);
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}regist_allcheck.pl";

# ���{�b�g�悯�Ȃ�
$no_headerset = 1;

	# �f���S�̂œ��e��~���̏ꍇ
	if(Mebius::Switch::stop_bbs()){ main::error("�f���S�̂œ��e��~���ł��B"); }

	# �n�샂�[�h�ݒ�
	if($main::bbs{'concept'} =~ /Sousaku-mode/) {
			if($category eq "poemer"){ our $min_msg = $s_min_msg; our $norank_wait = 1.0; }
			if($category eq "novel"){ our $norank_wait = 1.0; }
		our $new_min_msg = 50;
		our $ngbr = 400;
	}

	# �`���b�g���[�h�ݒ�
	if($main::bbs{'concept'} =~ /Chat-mode/){
		our $wait = 0.5;
		our $max_msg = 80;
		our $min_msg = 2;
		our $new_min_msg = 50;
		our $norank_wait = 0.5;
	}

# �g�єł̏ꍇ
#if($in{'res'}){ $kback_link_tell = "$main::in{'res'}.html"; }
if($in{'k'}){ kget_items(); }

	# �L�^���e�̒�` (�Ǘ����[�h)
	if(Mebius::Admin::admin_mode_judge()){
		my($my_admin) = Mebius::my_admin();

		#$pwd = '�Ǘ���';
		#if($in{'normal_user'} && $my_admin->{'master_flag'}){ $pwd = "��"; }
		# �M�����`
		$i_nam2 = $my_admin->{'name'};
		#if($in{'name'} && $my_admin->{'master_flag'}){ $i_nam2 = $in{'name'}; }
		if($in{'normal_user'} && $my_admin->{'master_flag'}){ $i_nam2 = qq(������䂤��); }
		else{
			our $new_res_concept .= qq(Admin-regist);
		}
		if($in{'nameplus'}){ $i_nam2 = "$i_nam2($in{'nameplus'})"; }	

	# �L�^���e�̒�` (�ʏ탂�[�h)
	} else {

		# ���͓��e���`
			if($in{'other_name'}){ our $i_nam = $in{'other_name'}; }
			else{ our $i_nam = $in{'name'}; }

	}

# �L�^���e�̒�` ( ���� )
our $i_com = $in{'comment'};
	if(Mebius::Admin::admin_mode_judge()){
		($i_com) = Mebius::Fixurl("Admin-to-normal",$i_com);
	}

	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($i_com)); }

our $i_res = $in{'res'};
$i_res =~ s/\D//g;
our $i_sub = $in{'sub'};


	# �T�C�g�S�̂̐V�����X����A�d�����e�̃`�F�b�N ( ���ׂĂ̕��͕ϊ����I�������ɔ��� )
	if(!Mebius::Admin::admin_mode_judge()){
		regist_double_check("",$i_com);
	}

	# ���[�h�ؑւ�
	if($mode eq "regist_resedit") { require "${init_directory}part_resedit.pl"; &thread_resedit(); }
	elsif($mode eq "regist") { &regist_bbs(); }

exit;

}


#-------------------------------------------------
# �L�����e����
#-------------------------------------------------
sub regist_bbs{

# �錾
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($i_resnumber,$i_postnumber,$i_sub,$image_data,$plustype_history_not_open);
my($my_account) = Mebius::my_account();
my $query = new CGI;
my $bbs_thread = new Mebius::BBS::Thread;
my $history = new Mebius::History;
my($content_create_time);
my($param) = Mebius::query_single_param();
my $encoding = new Mebius::Encoding;
my $all_comments = new Mebius::AllComments;

our($server_domain,$nextcharge_time,$time,%in,$host,$i_com,$i_sub,$i_nam,$i_res,$cnumber,$pmfile,$i_handle,$category,$moto,$realmoto,$secret_mode,$head_title,$crireki,$sexvio,$head_title,$e_com,$kaccess_one,$upload_file,$upload_flag,$new_res_concept,$rcevil_flag,$i_nam2,$encid);

# �A�N�Z�X����
($host) = main::axscheck();

#�g���b�v�t�^�AID�t�^
main::trip($i_nam);
if(Mebius::Admin::admin_mode_judge()){ $encid = "�Ǘ���"; }
else{ ($encid) = main::id(); }

	# �摜�Y�t
	if($main::bbs{'concept'} =~ /Upload-mode/){
		if($upload_flag){ main::upload(); }
		main::upload_setup();
	}


	# �X�^���v�̏��� ( �������҂��h�~�ׁ̈A��{�G���[�`�F�b�N���� �������J�E���g�����s����O�ɏ������� ) ( A-1 )
my($error_stamp) = Mebius::Stamp::regist_error({ FromEncoding => "sjis" },"comment");
	if($error_stamp){
			foreach(@$error_stamp){
				$e_com .= qq(��$_<br>);
			}
	}

# �s���ȃX�^���v���폜
($i_com) = Mebius::Stamp::erase_invalid_code($i_com);

# ��{�G���[�`�F�b�N (A-2)
main::base_error_check();

	# �e���v�������̂܂ܓ��e�ł��Ȃ��悤��
	if($main::bbs{'textarea_first_input'} && $main::bbs{'textarea_first_input'} eq $main::in{'comment'}){
		$main::e_com .= qq(�����e�t�H�[���̃e���v���[�g�����̂܂܏������ނ��Ƃ͏o���܂���B�K�v�ȕ�����ǉ��A�C�����Ă��������B<br$main::xclose>); 
	}

	# �����A�h�`�F�b�N
	if($main::in{'email'} && $main::in{'email_tell'} eq "tell"){
		my($error_format) = Mebius::mail_format(undef,$main::in{'email'});
			if($error_format){ $main::e_com .= qq(��$error_format<br$main::xclose>); }
	}

	# �{���ɉ摜��ǉ�
	if($upload_file){ ($i_com) = main::upload_com($i_com); }


my $comment_utf8 = utf8_return($i_com);
	if($all_comments->dupulication_error($comment_utf8)){
		$e_com .= "���d�����e�ł��B";
	}


	if($i_nam2){ $i_handle = $i_nam2; }

	# ���V�K���e
	if($i_res eq "") {
		require "${init_directory}part_post.pl";
		($i_postnumber,$i_resnumber,$i_sub) = regist_post("",$image_data);
		$content_create_time = time;
	}

	# �����X���e
	else{

		require "${init_directory}part_res.pl";
		($i_postnumber,$i_resnumber,$i_sub,$i_com,$new_res_concept,$content_create_time) =	regist_res("",$i_res,$i_handle,$i_com,$main::in{'color'},$encid,$main::myaccount{'file'},$new_res_concept,$image_data);
	}

	# ���X�Ď�
	if($main::bbs{'concept'} !~ /Sousaku-mode/){
		rcevil("$rcevil_flag","$i_com","$i_handle","http://$server_domain/_$moto/$in{'res'}.html-$i_resnumber","$i_sub");
	}

$all_comments->submit_new_comment($comment_utf8);

	# �����[�U�[��������
	if(!Mebius::Admin::admin_mode_judge()){

		# ���֘A�L�����쐬
		if(Mebius::alocal_judge() || $main::bbs{'concept'} =~ /Local-mode/ || ($crireki ne "off" && rand(3) < 1 && !$sexvio) ){
			require "${init_directory}part_kr.pl";
			open_kr("REGIST",$realmoto,$i_postnumber,$i_sub);
		}

		# ���t�H���[�p�t�@�C�����X�V
		my $bbs_status = new Mebius::BBS::Status;
		require "${init_directory}part_follow.pl";
		my $follow_regist = { server_domain => $main::server_domain , real_bbs_kind => $realmoto , bbs_kind => $moto , res_number => $i_resnumber, thread_number => $i_postnumber, last_handle => $i_handle, cnumber => $main::cnumber , account => $main::myaccount{'file'}, subject => $i_sub , regist_time => time , bbs_title => $main::title , last_update_time => time , all_regist_count => ['+','1'] };
		my $follow_regist_utf8 = Mebius::Encoding::hash_to_utf8($follow_regist);
		$bbs_status->update_main_table($follow_regist_utf8);

		# ���e�������L�^
		require "${init_directory}part_history.pl";

			# ���e�����X�V�́A���ʃR���Z�v�g ( ID / �g���b�v�����ȊO )
			if($main::crireki eq "off"){ $plustype_history_not_open .= qq( New-line-hidden); }

		# ���e�����ɋL�^������e
		my $postdata_history = "$i_sub<>$i_postnumber<>$i_resnumber<>$realmoto<>$head_title<>$server_domain<>$encid<>$in{'comment'}<>$nextcharge_time<><>$main::i_handle<>$main::encid<>";

			# ���e�������L�^�i�A�J�E���g�j 
			if($pmfile){
				get_reshistory("ACCOUNT RENEW REGIST My-file $plustype_history_not_open",$pmfile,undef,$postdata_history);
					if($query->param('account_link') && !Mebius::BBS::secret_judge()){
						get_reshistory("Open-account RENEW REGIST My-file",$pmfile,undef,$postdata_history);
					}
			}

			# ���e�������L�^�i�Ǘ��ԍ��j - Cookie���I�t�̊��ŁA$cnumber ���R���R���ς肻���ȏꍇ�͋L�^���Ȃ�
			if($cnumber){
				get_reshistory("CNUMBER RENEW REGIST My-file $plustype_history_not_open",$cnumber,undef,$postdata_history);
			}

			# ���e�������L�^�i�̎��ʔԍ��j
			if($kaccess_one){
				get_reshistory("KACCESS_ONE RENEW REGIST My-file $plustype_history_not_open",undef,undef,$postdata_history);
			}

			# ���e�������L�^�i�z�X�g���j
			else{
				get_reshistory("HOST RENEW REGIST My-file HOST $plustype_history_not_open",$host,undef,$postdata_history);
			}

			# ���e�������L�^�i�g���b�v�j
			if($main::trip_history_flag){
				get_reshistory("TRIP RENEW REGIST My-file",$main::enctrip,undef,$postdata_history);
			}

			# ���e�������L�^�iID�j
			my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
			if($id_history_judge->{'record_flag'}){
				get_reshistory("ENCID RENEW REGIST My-file",$main::pure_encid,undef,$postdata_history);
			}

			# 
			if($my_account->{'login_flag'}){

			}

			# ���e�������L�^�i�M���j
			{
				get_reshistory("HANDLE RENEW REGIST My-file $plustype_history_not_open",$main::i_handle,undef,$postdata_history);
			}


			# ���e�������L�^�iISP�j
			{
				get_reshistory("ISP RENEW REGIST My-file $plustype_history_not_open",undef,undef,$postdata_history);
			}

			# �O���T�C�g���o�R�����ꍇ
			if($main::mypenalty{'Hash->from_other_site_flag'}){
				Mebius::FromOtherSite("Renew New-regist");
				require "${init_directory}part_newlist.pl";
				Mebius::Newlist::threadres("RENEW From-other-site-file","","","","$realmoto<>$head_title<>$i_postnumber<>$i_resnumber<>$i_sub<>$i_handle<>$i_com<>$category<>$pmfile<>$encid<>");

			}

	}


	# ���m�点���[����z�M�i�閧�j
	#if($in{'res'} && $secret_mode){ sendmail_scres("SECRET",$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com); }

	# �A���[�g��˔j�����ꍇ�A���ӓ��e���L�^
	if($main::a_com && !Mebius::Admin::admin_mode_judge()){
		my($alert_type);
			foreach(@main::alert_type){
				$alert_type .= qq( $_);
			}
		require "${init_directory}part_newlist.pl";
		Mebius::Newlist::threadres("RENEW ECHECK","","","","$realmoto<>$head_title<>$i_postnumber<>$i_resnumber<>$i_sub<>$i_handle<>$i_com<>$category<>$pmfile<>$encid<>$alert_type");
	}
	
	# �S�Ă̓��e���L�^
	if(!Mebius::Admin::admin_mode_judge()){
		Mebius::BBS::ThreadStatus->update_table({ bbs_kind => $realmoto , thread_number => $i_postnumber , res_number => $i_resnumber , handle => utf8_return($i_handle) , subject => utf8_return($i_sub) , regist_time => time , category => $category });
	}

	{

		my $hidden_from_friends = $history->hidden_from_friends_judge_on_param();
 

		my $subject_utf8 = utf8_return($i_sub);
		my $handle_utf8 = utf8_return($i_handle);


	#if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($handle_utf8)); }

		my %insert_for_history = ( bbs_kind => $realmoto , thread_number => $i_postnumber , subject => $subject_utf8 , handle => $handle_utf8 , last_response_num => $i_resnumber , last_response_target => $i_resnumber , content_create_time => $content_create_time , hidden_from_friends_flag => $hidden_from_friends );
			if($i_res eq "") {
				$bbs_thread->create_common_history_on_post(\%insert_for_history);
			} else {
				$bbs_thread->create_common_history(\%insert_for_history);
			}
	}

# ���e��̉�ʂ�
require "${init_directory}part_posted.pl";
regist_posted("",$i_postnumber,$i_resnumber,$i_sub,$i_com);

exit;

}

#-----------------------------------------------------------
# ��{�G���[�`�F�b�N
#-----------------------------------------------------------
sub base_error_check{

# �錾
my($type) = @_;
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my(%reshistory,$doubleflag);
our(%in,$emd,$xclose,$category,$new_res_concept,$i_com,$i_sub,$host,$min_msg,$e_com,$i_handle,$i_res,$concept,$moto,$pmfile,$max_msg,$e_access,$cookie,$ngbr,$postflag,$getflag,$k_access,$deconum,$brnum);

# �J�e�S���ݒ���擾
my($init_category) = Mebius::BBS::init_category();

	# �z�X�g���Ȃ���Ύ擾
	if(!$host){
		our($host) = Mebius::GetHostWithFile();
	}

	# �I�[�o�[�t���[�`�F�b�N
	Mebius::Regist::OverFlowCheck(undef,$main::in{'comment'});

	# �e��G���[
	if(!$postflag && !$getflag) { $e_access .= qq(���s���ȃA�N�Z�X�ł��B<br>); }

# ��荞�ݏ���
require "${init_directory}regist_allcheck.pl";

# ��{�ϊ�
($i_com) = &base_change($i_com);

	# ���Xj�R���Z�v�g���` - �t�H���g�̎��
	if(($i_com =~ s/\[����\]//g) >= 1){ $new_res_concept .= qq( Fontfamily<'�l�r �S�V�b�N'>); }

	# ���Xj�R���Z�v�g���` - �g���b�v���e����
	if($main::enctrip && $main::trip_concept !~ /Not-history/ && !Mebius::BBS::secret_judge() && !Mebius::Admin::admin_mode_judge()){
		$new_res_concept .= qq( Tripory);
		$main::trip_history_flag = 1;
	}

	# ���Xj�R���Z�v�g���` - ID���e����
	my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });

	if($id_history_judge->{'record_flag'} && !Mebius::SNS::admin_judge()){
		$new_res_concept .= qq( Idory5);
	}

	# ���Xj�R���Z�v�g���` - �A�J�E���g���̋L�^
	if($pmfile){ 
			if($in{'account_link'}){
					if(!Mebius::BBS::secret_judge()){	$new_res_concept .= qq( Accountory); }
			}	else{
				$new_res_concept .= qq( Hide-account);
			}
	}

	# ���X�R���Z�v�g���` - �O���T�C�g�o�R�̃��[�U�[
	if($main::mypenalty{'Hash->from_other_site_flag'}){
		$new_res_concept .= qq( From-other-site-$main::mypenalty{'Hash->from_other_site_file_type'});
	}

	# �X�p���΍�
	if(!$cookie && !$k_access && $host !~ /(\.jp$|\.com$|\.net$|^localhost$)/){
		$e_access = qq(�����O����̃X�p�����u���b�N���ł��i�e�X�g�^�p�j�B���M�ł��Ȃ��ꍇ��<a href="http://aurasoul.mb2.jp/etc/mail.html">���[���t�H�[��</a>���炨�m�点���������B<br>);
	}


	# ���s����
	if($brnum > $ngbr) {
		$e_com .= "�����s���������܂��B���s���������炵�Ă��������B�i ����$brnum�� / �ő�$ngbr�� �j<br>";
		Mebius::Echeck("","BR-OVER-ERROR",$i_com);
	}

# �v���X���[�h
my($plustype_registcheck);
if($main::bbs{'concept'} =~ /Sousaku-mode/){ $plustype_registcheck .= qq( Sousaku); }

	# ���[�J�����őS�`�F�b�N�����
	if((Mebius::alocal_judge() && $main::in{'comment'} =~ /break/) || Mebius::Admin::admin_mode_judge()){ 

	# ���ʂɔ���
	}else{

		# �e��`�F�b�N
		Mebius::Regist::private_check("$plustype_registcheck Sjis-to-utf8",$i_com,$category,$concept);

			# �G�k��/�`���b�g������
			if(($main::bbs{'concept'} =~ /Block-convesation/ || $init_category->{'concept'} =~ /Block-convesation/) 
			&& $main::bbs{'concept'} !~ /Allow-convesation/){
				Mebius::Regist::ConvesationCheck("$plustype_registcheck",$i_com,$category,$concept);
			}

			#  && $i_res ne "" #�V�K���e���͔���������ꍇ
			if($moto ne "btn"){ Mebius::Regist::ChainCheck("$plustype_registcheck",$i_com,$category,$concept); }
		&url_check("$plustype_registcheck",$i_com,$category,$concept);
		Mebius::Regist::sex_check("$plustype_registcheck Sjis-to-utf8",$i_com,$category,$concept);
		Mebius::Regist::EvilCheck("$plustype_registcheck",$i_com,$category,$concept);

		(undef,$deconum)  = &deco_check("$plustype_registcheck",$i_com,$category,$concept) if($moto ne "delete");
		space_check("$plustype_registcheck",$in{'comment'},$category,$concept);	# ������ $in{'comment'}
		shift_jis(($i_handle) = Mebius::Regist::name_check($i_handle));
	}

	# �薼�̊�{�`�F�b�N
	if($i_res eq ""){ ($i_sub) = &subject_check("$plustype_registcheck",$i_sub,$category,$concept); }

# �������`�F�b�N
our($bglength,$smlength) = &get_length("Decoration-cut",$in{'comment'},$deconum);

# �����F�`�F�b�N
($in{'color'}) = Mebius::Regist::color_check(undef,$in{'color'});

	# ���X���e�̕���������
	if($i_res && !Mebius::Admin::admin_mode_judge()) {
			if ($bglength > $max_msg) { $e_com .= "���{���̕��������������܂��B�i ����$bglength���� / �ő�$max_msg���� �j<br>"; $emd = 1; }
			if ($smlength < $min_msg && $main::bbs{'concept'} !~ /Local-mode/) { $e_com  .= qq(���{���̕����������Ȃ����܂��B�i ����$smlength���� / �ŏ�$min_msg���� �j<br>); $emd++; }
	}

	# ���ʂ̔���
	if(($i_com eq "")||($i_com =~ /^(\x81\x40|\s|<br>)+$/)) { $e_com .= "���{��������܂���B���������Ă��������B<br>"; $emd = 1; }

}

#-----------------------------------------------------------
# ���m�点���[���𑗐M - strict
#-----------------------------------------------------------
sub thread_sendmail_res{

# �Ǐ���
my($type,$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com) = @_;
my($body1,$body2,$subject,$open,$text,$text_length,$timeout_flag,$sendmail_handler);
our($alocal_mode,$secret_mode,$int_dir,%in,$title,$server_domain,$myadmin_flag);
our($cemail,$thishour,$moto);

# URL
my $url = "_$moto";

# �����`�F�b�N
$moto =~ s/\W//g;
$i_postnumber =~ s/\D//g;
	if($moto eq "" || $i_postnumber eq ""){ return; }

	# �{���̏ȗ�
	foreach( split(/<br>/,$i_com) ){
			if($text_length < 50){ $text .= qq(${_} ); }
		$text_length += length $_;
	}

# �閧��
if($secret_mode){ $text = qq(���e�͌f���Ŋm�F���Ă�������); }

# ����
$subject = qq(�u$i_sub�v�� $i_handle���� �����e���܂���);

# �m�[�}���̕���
$body1 = qq(���r�E�X�����O�́y$title�z�ɍX�V���������̂ŁA���m�点�������܂��B

��$i_handle > $text �c

��$i_sub - $title
  http://$server_domain/_$moto/$i_postnumber.html

�����X��\\��
  http://$server_domain/_$moto/$i_postnumber.html#S$i_resnumber
);

# �V���v���ȕ���
$body2 = qq(URL:http://$server_domain/_$moto/${i_postnumber}.html#S$i_resnumber
);

# �z�M�p�t�@�C�����J��
open($sendmail_handler,"<","$main::bbs{'data_directory'}_sendmail_${moto}/${i_postnumber}_s.cgi") || return();

	# �t�@�C����W�J
	while(<$sendmail_handler>){

		# ����
		chomp;
		my($body);
		my($address2) = split(/<>/,$_);
		my($address_encoded2) = Mebius::Encode(undef,$address2);

		# �A�h���X�P�̃t�@�C�����擾
		my(%address) = Mebius::Email::address_file(undef,$address2);
		if($address{'deny_flag'}){ next; }

		if($address{'mail_type'} eq "mobile"){ $body = $body2; } else { $body = $body1; }

		my($flag,$mobile) = Mebius::mail_format(undef,$address2);

		$body .= qq(\n\n);
		$body .= qq(�z�M�����i�P�N���b�N�j\n);
		$body .= qq(http://$server_domain/_$moto/?mode=cermail&type=cancel&moto=$moto&no=$i_postnumber&char=$address{'char'}&email=$address_encoded2);

		# �����̃��X�̏ꍇ
		if($cemail && $address2 eq $cemail && $myadmin_flag < 5){ next; }
		 
		# ���[�����M
		if($address2){ Mebius::send_email("Edit-url-plus",$address2,$subject,$body); }

	}
close($sendmail_handler);

}

#-------------------------------------------------
# ���e���̃����N���� - strict
#-------------------------------------------------
sub bbs_regist_auto_link{

# �錾
my($msg) = @_;
our(%in,$i_res);

# ���������N
($msg) = Mebius::auto_link({ BlankWindow => 1 },$msg);

	if(!$in{'k'}){ $msg =~ s/No\.([0-9]{1,5})(([,-])([0-9,]+)||$)/<a href=\"${i_res}.html-$1$2\">&gt;&gt;$1$2<\/a>/g; }

# ���^�[��
return($msg);

}


#-------------------------------------------------
# �G���[�����̐U�蕪�� - strict
#-------------------------------------------------
sub regist_error{

# �錾
my($init_directory) = Mebius::BaseInitDirectory();
my($param) = Mebius::query_single_param();

	# �U�蕪��
	if($param->{'k'} == 1){ require "${init_directory}k_rerror.pl"; regist_mobile_rerror(@_); }
	else{ require "${init_directory}part_resform.pl"; regist_rerror(@_); }

}

1;

