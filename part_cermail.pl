
use strict;
use Mebius::Auth;
use Mebius::BBS;
package Mebius::Email;

#-----------------------------------------------------------
# �f���L���̃��[���F��
#-----------------------------------------------------------
sub CermailStart{

	# �g�у��[�h
	if($main::device{'type'} eq "Mobile"){ main::kget_items(); }

# ���y�A����
$main::not_repair_url_flag = 1;

# �����悯
$main::noindex_flag = 1;

# ���L���t�@�C�����J��
my($thread) = Mebius::BBS::thread_state($main::in{'no'},$main::moto);

# �����N��`
$main::head_link3 = qq( &gt; <a href="$main::in{'no'}.html">$thread->{'subject'}</a>);
$main::head_link4 = qq( &gt; ���m�点���[���o�^);

	# ���[�h�U�蕪��	# �o�^�폜
	if($main::in{'type'} eq "cancel"){
		CancelMailBBSThread(undef,$main::in{'email'},$main::in{'char'},$main::moto,$main::in{'no'});
	# �m�F���[���̔z�M
	} elsif($main::in{'type'} eq "send_cermail"){
		my($error_flag) = SendCermail("BBS-thread From-form Set-cookie View-HTML",$main::in{'email'},$main::moto,$main::in{'no'});
			if($error_flag){ main::error("$error_flag"); }
	# ?
	}	else {
		FormSendCermailThread();
	}

}

#-----------------------------------------------------------
# ���m�点���[���o�^�t�H�[�� - �f���̋L���p
#-----------------------------------------------------------
sub FormSendCermailThread{

# �Ǐ���
my($myaddress) = Mebius::my_address();
my($top);
my($guide_text1,$alert_text,$mail_input,$mail_submit,$cancel_hidden,$type_input);

# �����A�h���̓o�^�󋵂̎擾
my($still_flag) = Mebius::Email::BBSThread("Still-check",$myaddress->{'address'},$main::moto,$main::in{'no'});

# ���L���t�@�C�����J��
my(%thread) = Mebius::BBS::thread({},$main::moto,$main::in{'no'});

# CSS��`
$main::css_text .= qq(
.mail{width:15em;}
.manual{font-size:90%;border:solid 1px #666;padding:1em 2em;line-height:1.5em;margin-top:2em;}
);

# �^�C�g����`
$main::sub_title = "���[���z�M�o�^ | $thread{'subject'}";

# �t�H�[�J�X�𓖂Ă�
$main::body_javascript = qq( onload="document.cermailform.email.focus()");

# ���������` - �F�؍ς݂̏ꍇ
$guide_text1 = qq(
<div class="line-height">
�����Ń��[���A�h���X��o�^����ƁA<br$main::xclose>
<a href="./">$main::title</a>��<a href="$main::in{'no'}.html">$thread{'subject'}</a>�ɏ������݂��������Ƃ��A
���[���ł��m�点���͂��܂��B
</div><br$main::xclose>
);

	# ���ӏ������` - �F�؍ς݂̏ꍇ
	if($myaddress->{'myaddress_flag'}){
		$alert_text = qq(
		<br$main::xclose><br$main::xclose><span class="red">
		��<a href="${main::main_url}?mode=my">�}�C�y�[�W</a>�ł����m�点���[���̊Ǘ��A�������o���܂��B</span>);
	}
	# ���ӏ������` - �F�؂Ȃ��̏ꍇ
	else{
		$alert_text = qq(
		<br$main::xclose><br$main::xclose>
		<div class="red line-height">
		���C�^�Y���h�~�̂��߁A���͂��ꂽ���[���A�h���X�ɁA���Ȃ��́u�h�c���v�u�h�o�i�ڑ����j�v�Ȃǂ����M����܂��i�{�l�̃A�h���X�ł���ꍇ�́A��肠��܂���j�B<br$main::xclose>
		�����m�点���[���ɏ����ꂽ�u�����p�t�q�k�v�ɃA�N�Z�X���邱�ƂŁA�L�����Ƃ̔z�M�������o���܂��B
		</div>);
	}

	# �F�؍ς݁��o�^�ς݂̏ꍇ
	if($still_flag eq "Still"){
		$mail_submit .= qq(<input type="submit" value="���m�点���[������������"$main::xclose>\n);
		$mail_submit .= qq(<input type="hidden" name="email" value="$myaddress->{'address'}"$main::xclose>\n);
		$mail_input .= qq(<strong style="color:#f00;">$myaddress->{'address'}</strong>);
		$mail_input .= qq(<input type="hidden" name="email" value="$myaddress->{'address'}"$main::xclose>);
		$guide_text1 = qq(���̋L�� ( $thread{'subject'} )�ɂ͂��m�点���[����<strong style="color:#00f;">�o�^�ς�</strong>�ł��B�@�������܂����H<br$main::xclose><br$main::xclose>);
		$cancel_hidden = qq(<input type="hidden" name="cancel" value="1"$main::xclose>);
		$type_input = "cancel";
	}

	# �F�؍ς�
	elsif($myaddress->{'myaddress_flag'}){

		# ���L���̃L�[���Ȃ��ꍇ 
		if($thread{'keylevel'} < 1){ main::error("���̋L���ɂ͂��m�点���[����o�^�ł��܂���B"); }

		# ���[���p�[�c���`
		$mail_input .= qq(<input type="text" name="email" value="$myaddress->{'address'}" class="mail" id="cermail_address"$main::xclose>);
		$mail_input .= qq(�@<strong style="color:#f00;">(�F�؍ς�)</strong>);
		$mail_submit .= qq(<input type="submit" value="���̃A�h���X��o�^����"$main::xclose>\n);

		$type_input = "send_cermail";
	}

	# �F�؂Ȃ�
	else{

		# ���L���̃L�[���Ȃ��ꍇ 
		if($thread{'keylevel'} < 1){ main::error("���̋L���ɂ͂��m�点���[����o�^�ł��܂���B"); }
	
		# ���[���p�[�c���`
		$mail_input .= qq(<input type="text" name="email" value="$main::cemail" class="mail" id="cermail_address"$main::xclose>);
		$mail_submit = qq(<input type="submit" value="�z�M�m�F���[���𑗂�"$main::xclose>);
		$type_input = "send_cermail";
	}


	if(Mebius::Switch::stop_bbs()){ $mail_input = ""; $mail_submit = qq(<span class="alert">�����݁A�o�^�o���܂���B</span>); }

# HTML
my $print = <<"EOM";
<h1>���m�点���[���o�^</h1>
$guide_text1
<form action="./?regist" method="post" name="cermailform"$main::sikibetu><div>
<label for="cermail_address">���[���A�h���X</label>
$mail_input
$mail_submit
$cancel_hidden
<input type="hidden" name="mode" value="cermail"$main::xclose>
<input type="hidden" name="type" value="$type_input"$main::xclose>
<input type="hidden" name="moto" value="$main::moto"$main::xclose>
<input type="hidden" name="no" value="$main::in{'no'}"$main::xclose>
<input type="hidden" name="action" value="1"$main::xclose>
$alert_text
</div></form>
EOM

	# �o�^���̏ڂ���������
	if($type_input ne "cancel"){
		$print .= qq(
		<ul class="manual">
		<li>�o�^��Ƃ�����ƁA��x�m�F���[�����͂��܂��B���ɋL�ڂ��ꂽ�t�q�k�ɃA�N�Z�X����ƁA���m�点�z�M���J�n���܂��B</li>
		<li>�����ǔF�؍�Ƃ��ς܂��ƁA������̓_�C���N�g�ɓo�^�ł���悤�ɂȂ�܂��i�������A���ɂ��܂��j�B</li>
		<li>���m�点������̂́A�u<a href="./">$main::title</a>�v�́u<a href="$main::in{'no'}.html">$thread{'subject'}</a>�v�ɏ������݂��������Ƃ������ł��B�i�f���S�̂ł͂���܂���j</li>
		<li>�����̋L���ɂ��m�点���~�����Ƃ��́A�L�����Ƃɓo�^��Ƃ����Ă��������B</li>
		<li>���Ȃ��̃��[���A�h���X�ȊO�͓o�^���Ȃ��ł��������B</li>
		</ul>
		);
	}

# �t�b�^
Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}

#-----------------------------------------------------------
# �m�F���[����z�M����
#-----------------------------------------------------------
sub SendCermail{

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$address) = @_;
my($moto,$no,$account);
if($type =~ /BBS-thread/) { (undef,undef,$moto,$no) = @_; }
if($type =~ /SNS-account/) { (undef,undef,$account) = @_; }
my($top,$top_deny1,$top_deny2,$line,$i_cermail,$link1,$flow,$line_submitout,$error_message);
my($cermail_url,%thread,$guide_cermail,$mail_body,$mail_subject,$plustype_mailaddress);
my(%renew_address,$message_line);

# �T���v���A�h���X
if($address =~ /example\@ne.jp/){ return(); }

# ���e����
main::axscheck("Deny-bot");

# �h�c�t�^
my($encid) = main::id();

# ���[���A�h���X�P�̃f�[�^���擾
my(%address) = Mebius::Email::address_file("Get-hash-detail Skip-undelivered-count",$address);

	# �e��G���[
	if(!$address{'myaddress_flag'}){
			if($address{'deny_flag'}){ return($address{'deny_flag'}); }
			if($address{'deny_sendcermail_flag'}){ return($address{'deny_sendcermail_flag'}); }
	}

# E-Mail�̏����`�F�b�N
my($error_flag_mailformat,$address_type) = Mebius::mail_format(undef,$address);
	if($error_flag_mailformat){ return($error_flag_mailformat); }
	# �g�тւ̐[��̑��M���֎~
	if(!$address{'myaddress_flag'} && $address_type eq "mobile"){
			if($main::thishour <= 6 && $main::thishour >= 0){ return("���̎��ԑ�(0��-6��)�͌g�тɔF�؃��[���𑗂�܂���B"); }
	}

# ���f��񂪂���ꍇ�A�u���b�N
my($error_flag_access_check) = Mebius::Email::AccessCheck(undef,$main::addr,$main::cnumber);
	if($error_flag_access_check){ return($error_flag_access_check); }

	# �^�C�g����`
	if($type =~ /View-HTML/){ $main::sub_title = "�m�F���[���̔z�M"; }

	# ���f���̋L���p�̃`�F�b�N
	if($type =~ /BBS-thread/){

			# �Ǐ���
			my($redun_thread_flag,$thread_sendmail_handler);

			# �����`�F�b�N
			if($moto eq ""){ return("�f�����w�肵�Ă��������B"); }
			if($no eq ""){ return("�L�����w�肵�Ă��������B"); }
			if($moto =~ /\W/){ return("�m�F���[����z�M���悤�Ƃ��܂������A�f���̎w�肪�ςł��B"); }
			if($no =~ /\D/){ return("�m�F���[����z�M���悤�Ƃ��܂������A�f���̎w�肪�ςł�"); }

			# ���L���t�@�C�����J��
			(%thread) = Mebius::BBS::thread({},$moto,$no);

				# �L�[���Ȃ��ꍇ ( + �����`�F�b�N�����˂� )
				if($thread{'keylevel'} < 1){ return("���̋L���ɂ͂��m�点���[����o�^�ł��܂���B"); }

			# �L���z�M�p�t�@�C�����J���A��d�o�^�`�F�b�N�A
			open($thread_sendmail_handler,"$main::bbs{'data_directory'}_sendmail_${moto}/${no}_s.cgi");
				while(<$thread_sendmail_handler>){
					chomp;
					my($address2,$char2,$mailtype2) = split(/<>/,$_);
						if($address2 eq $address){ $redun_thread_flag = 1; }
				}
			close($thread_sendmail_handler);
				if($redun_thread_flag && !$main::alocal_mode){ return("���̋L���ɁA���̃��[���A�h���X�͓o�^�ς݂ł��B"); }

			# �����ɔF�؍ς݂̏ꍇ�A�_�C���N�g�o�^����
			if($address{'myaddress_flag'}){
				my($error_flag) = BBSThread("Renew New-line",$address,$moto,$no,$thread{'sub'},$main::title);
					# �G���[
					if($error_flag){ return($error_flag); }
					# ����
					else{
						# ���O�̋L�^
						Mebius::AccessLog(undef,"Send-cermail-direct");
						# �����A�h�t�@�C���̐ڑ��f�[�^�����A�ŐV�̏�Ԃɂ���
						Mebius::Email::address_file("Renew Renew-myaccess",$address);
							# �������ă��^�[������ꍇ ( ���X���e���Ȃ� )
							if($type =~ /Post-regist/){
								return(undef,"���m�点���[����o�^���܂����B");
							}
							# �o�^�������b�Z�[�W��\�����ďI�� ( �t�H�[������̓o�^ )
							else{
								$main::jump_sec = 1;
								$main::jump_url = "./$no.html";
								my $print = qq(���m�点���[����o�^���܂����B(<a href="$main::jump_url">���߂�</a>));
								Mebius::Template::gzip_and_print_all({},$print);
								exit;
							}
					}
			}

	}

# �A�����M���֎~
my($redun_flag) = Mebius::Redun("Get-only","Send-cermail",1*60);
if($redun_flag){ return("�A�����Ċm�F���[���͑��M�ł��܂���B���΂炭���҂����������B"); }

	# �o�^�^�C�v ( ���ɔF�ؐ��������ꍇ�̏��� ) ���` 
	if($type =~ /BBS-thread/){
		$renew_address{'cer_type'} = "$address{'cer_type'} BBS-thread-$moto-$no";
		$guide_cermail .= qq(\n�o�^��̋L���F $thread{'subject'} http://$main::server_domain/_$moto/$no.html\n);
	}
	elsif($type =~ /SNS-account/){
		$renew_address{'cer_type'} = "$address{'cer_type'} SNS-account-$account";
	}

# �����A�h�P�̃t�@�C�����A�m�F��Ԃɂ���i�t�@�C���X�V�A$char ���擾�j
my(%renewed_address) = Mebius::Email::address_file("Send-cermail Renew",$address,%renew_address);

# ���[���A�h���X�̃G���R�[�h
my($address_enc) = Mebius::Encode(undef,$address);

# �F�ؗp��URL���`
$cermail_url .= "${main::main_url}?mode=address&type=cermail&char=$renewed_address{'cer_char'}";
$cermail_url .= "&mailtype=$main::in{'mailtype'}&email=$address_enc";

# ���[������
my $mail_subject = qq(���[���z�M�m�F -���r�E�X�����O);

# ���[���{��
$mail_body = qq(���r�E�X�����O ( http://$main::server_domain/ ) �ŁA���Ȃ��̃��[���A�h���X����M�p�Ƃ��Đݒ肵�܂��B
$guide_cermail
���[���A�h���X�͔���J�ŁA���m�点�z�M�ȊO�ɂ͎g���܂���B
��낵����΁A���̂t�q�k�ɃA�N�Z�X���Ă��������B
$cermail_url

�����M�ҏ��

�M��: $main::chandle
ID: $encid
IP�A�h���X: $main::addr
UA: $main::agent
);


# �m�F���[���𑗐M�A���[���P�̃t�@�C�����m�F�p�Ƃ��čX�V
my($keep_mailbody) = Mebius::send_email("Get-mailbody Edit-url-plus",$address,$mail_subject,$mail_body);

# �A�����M�֎~�t�@�C�����X�V
my($redun_flag) = Mebius::Redun("Renew-only","Send-cermail",1*60);

# ���O�̋L�^
Mebius::AccessLog(undef,"Send-cermail");

	# �N�b�L�[�Z�b�g
	if($type =~ /Set-cookie/){
		Mebius::Cookie::set_main({ email => $address },{ SaveToFile => 1 });
	}


# ���[�J���p�̃��b�Z�[�W���e���`
my($alocal_view);
if($main::alocal_mode){
	$alocal_view .= qq(<hr$main::xclose>���[�J���\\��<hr$main::xclose>);
	$alocal_view .= qq(<a href="$cermail_url">�F��</a> / );
	#$alocal_view .= qq(<a href="$denymail_url">����</a>);
	my $mail_body_alocal = $keep_mailbody;
	$alocal_view .= qq(<br$main::xclose><br$main::xclose>$mail_body_alocal);
}

# ���b�Z�[�W���e���`
$message_line .= qq(���r�E�X�����O��� &lt; <a href="mailto:$address">$address</a> &gt; ���Ɋm�F���[���𑗐M���܂����B<br$main::xclose>\n);
$message_line .= qq(���̂܂܁A���Ȃ��̃��[���{�b�N�X�����m�F���������B<br$main::xclose><br$main::xclose>\n);
$message_line .= qq(<span class="red">���܂��o�^�͊������Ă��܂���B</span><br$main::xclose><br$main::xclose>\n);
$message_line .= qq(���[�����͂��Ȃ��ꍇ�́A���[���A�h���X�����������͂���Ă��邩�ǂ��������m�F���������B<br$main::xclose>\n);
$message_line .= qq(�������� $basic_init->{'top_level_domain'} �̃h���C�����A���f���[���ݒ肩�珜�O���Ă��������B<br$main::xclose>\n);
	if($type =~ /BBS-thread/ && $type !~ /Post-regist/){
		$message_line .= qq(<a href="$no.html">�����̋L���ɖ߂�</a> / <a href="./">��$main::title�ɖ߂�</a>\n);
	}
$message_line .= qq($alocal_view\n);

	# HTML��\��
	if($type =~ /View-HTML/){

		# HTML�����o��
		my $print .= qq(<div class="line-height">);
		$print .= qq($message_line);
		$print .= qq(</div>);
		Mebius::Template::gzip_and_print_all({},$print);

		# �I��
		exit;

	}

return(undef,$message_line);

}

#-----------------------------------------------------------
# ���[���F�� ( �{�l�m�F ) �����s����
#-----------------------------------------------------------
sub Cermail{

# �Ǐ���
my($type,$address,$char) = @_;
my($line,$line2,$line3,$flag,$file);
my($thread_moto,$thread_number,$back_link,$message,$foreach,$submit_type);

# �A�N�Z�X����
main::axscheck();

# ID���擾 ( $cnumber ���Z�b�g )
main::id();

# ���[���A�h���X�P�̃f�[�^���擾
my(%address) = Mebius::Email::address_file("Get-hash-detail",$address);

	# �e��G���[
	if($address eq ""){ main::error("���[���A�h���X���w�肵�Ă��������B"); }
	if($char eq ""){ main::error("�F�ؗp�̃L�[���w�肵�Ă��������B"); }
	if(!$address{'waitcer_flag'}){ main::error("���Ԃ��o�߂������Ă��邩�A���ɔF�؍ς݂̂��߁A�F�؂ł��܂���B"); }
	if($char ne $address{'cer_char'}){ main::error("�F�ؗp�̃L�[���Ⴂ�܂��B"); }

	# ���o�^�^�C�v�����ׂēW�J
	foreach $foreach (split(/\s/,$address{'cer_type'})){

			# ���f���L���̂��m�点���[���o�^
			if($foreach =~ /BBS-thread-(\w+)-(\d+)/){


				# �Ǐ���
				my($thread_sendmail_handler);
				# ���f���A���L�����`
				$thread_moto = $1;
				$thread_number = $2;

				my(%thread) = &BBSThread("Renew New-line Get-hash-thread",$address,$thread_moto,$thread_number);
				$main::jump_url = "/_$thread_moto/$thread_number.html";
				if($thread{'subject'}){ $message .= qq( $thread{'subject'} ); }
				$submit_type = "BBS-thread";
			}

			#��SNS�̃A�J�E���g���[���F��
			if($foreach =~ /SNS-account-(\w+)/){

				my $account = $1;
				# �A�J�E���g�̃��[���A�h���X���X�V
				my(%renew_account);
				$renew_account{'email'} = $address;
				$renew_account{'mlpass'} = $address{'cer_char'};
				Mebius::Auth::File("Renew",$account,\%renew_account);
				$main::jump_url = "${main::auth_url}$account/";
				$submit_type = "SNS-account";
			}
	}

	# �o�^�^�C�v���w�肳��Ă��Ȃ��ꍇ
	if($submit_type eq ""){	$main::jump_url = "$main::main_url?mode=my"; }

# �����A�h���̊�{�t�@�C�����X�V
my(%renew_address) = Mebius::Email::address_file("Renew Cer-finished",$address);

# �^�C�g����`
$main::sub_title = "���[���A�h���X�̔F��";

	# �}�C�y�[�W����̔z�M�����̏ꍇ�A���_�C���N�g
	if($main::in{'my'}){
		Mebius::Redirect(undef,"${main::main::url}?mode=my#CERMAIL");
	}

# �y�[�W�W�����v�b��
$main::jump_sec = 1;

# �N�b�L���[�Z�b�g
Mebius::Cookie::set_main({ email => $address },{ SaveToFile => 1 });

	# ���[�J���\��
	my($alocal_view);
	if($main::alocal_mode){
		$alocal_view .= qq(<hr$main::xclose>���[�J���p<hr$main::xclose>);
		$alocal_view .= qq(<br$main::xclose><br$main::xclose>);
		$alocal_view .= qq(<a href="./?mode=cermail&type=cancel&no=$main::in{'no'}&char=$renew_address{'char'}">����</a>);
	}

# HTML
my $print = <<"EOM";
<div class="line-height">
���[���A�h���X�F�؂ɐ������܂��� (<a href="$main::jump_url">���߂�</a>)�B<br$main::xclose>
$message
</div>
$alocal_view
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}


#-----------------------------------------------------------
# ���m�点���[���̔z�M���� ( �E�F�u�y�[�W��ʂ��Ă̏����A�L���P�� )
#-----------------------------------------------------------
sub CancelMailBBSThread{

# �Ǐ���
my($myaddress) = Mebius::my_address();
my($type,$address,$char,$thread_moto,$thread_number) = @_;
my($line,$flag,$file,$mail,$message);

# �A�h���X�����͂̏ꍇ ( �}�C�y�[�W����̍폜�p )
if($address eq ""){ $address = $myaddress->{'address'}; }

# ���[���A�h���X�P�̃t�@�C�����擾
my(%address) = Mebius::Email::address_file("Get-hash-detail",$address);

	# Cookie�ŔF�؂���ꍇ ( �� $myaddress-> �ł͂Ȃ��A�{���[�v���� $address �Ŕ��� )
	if($address{'myaddress_flag'}){}
	# char �ŔF�؂���ꍇ
	else{
			if($char eq ""){ main::error("���[���̔F�؃L�[���w�肵�Ă��������B"); }
			if($char ne $address{'char'}){ main::error("���[���̔F�؃L�[���Ⴂ�܂��B"); }
	}

# �f���L���̑��M�p�t�@�C�����̔��聨�t�@�C���X�V
my($error_flag) = &BBSThread("Renew Cancel",$address,$main::in{'moto'},$main::in{'no'});
if($error_flag){ main::error("$error_flag"); }

# �^�C�g����`
$main::sub_title = "�z�M����";

	# �}�C�y�[�W����̔z�M�����̏ꍇ�A���_�C���N�g
	if($main::in{'my'}){
		my ($backurl_enc_cancel) = Mebius::Encode(undef,"http://$main::base_server_domain/_$thread_moto/$thread_number.html");
		Mebius::Redirect(undef,"http://$main::base_server_domain/_main/?mode=my&backurl=$backurl_enc_cancel#CERMAIL");
	}

# �W�����v
$main::jump_sec = 1;
$main::jump_url = "./$thread_number.html";


# HTML
my $print = <<"EOM";
<div class="line-height">
���[���z�M���������܂����B�i�����̋L���̔z�M����~����ꍇ�́A�P�ʂ��Ƃɒ�~�����������Ȃ��Ă��������j<br$main::xclose>

�܂��̂����p���A���R���R��肨�҂����Ă���܂��B<br$main::xclose><br$main::xclose>
<a href="./?mode=cermail&amp;no=$thread_number">�ēo�^</a> / <a href="./$thread_number.html">�L���ɖ߂�</a> / <a href="./">���f���ɖ߂�</a>
</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}

#-----------------------------------------------------------
# SNS���[���́A�z�M���[������̃N���b�N����
#-----------------------------------------------------------
sub CancelMailSNSAccount{

# �錾
my($type,$account,$char) = @_;
my(%renew,$file);

# �t�@�C�����J��
my(%account) = Mebius::Auth::File(undef,$account);

# �e��
if($char eq ""){ &error("�����p�p�X���[�h���w�肵�Ă��������B"); }
if($account{'mlpass'} eq ""){ &error("�F�؂���Ă��Ȃ����[���A�h���X�ł��B"); }
if($account{'email'} eq ""){ &error("���[���A�h���X�o�^������܂���B"); }
if($account{'mlpass'} ne $char){ &error("�����p�p�X���[�h���Ⴂ�܂��B"); }


# ���[���A�h���X������
$renew{'email'} = "";
$renew{'mlpass'} = "";

# �t�@�C���X�V
Mebius::Auth::File("Renew",$account,\%renew);

# �W�����v��
$main::jump_sec = 10;
$main::jump_url = "$main::auth_url$account/";


# HTML
my $print = qq(SNS�̃��[���z�M���������܂����B(<a href="$main::jump_url">���߂�</a>));

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# �f���L���ւ̓o�^
#-----------------------------------------------------------
sub BBSThread{

# �錾
my($type,$address,$thread_moto,$thread_number,$thread_subject,$bbs_title) = @_;
my($career_handler,$thread_sendmail_handler,@renewline_career,@renewline_thread_sendmail,%thread,$still_flag);

# �����`�F�b�N
if($thread_moto eq "" || $thread_moto =~ /\W/ || $thread_moto =~ /^(sc|sub)/){ return("�f�����w�肵�Ă��������B"); }
if($thread_number eq "" || $thread_number =~ /\D/){ return("�L�����w�肵�Ă��������B"); }
my($address_enc) = Mebius::Encode(undef,$address);
if($address_enc eq ""){ return("���[���A�h���X���w�肵�Ă��������B"); }

# �f���p�̃t�@�C�������擾
my($bbs_file) = Mebius::BBS::InitFileName(undef,$thread_moto);

# �t�@�C�� /�f�B���N�g����`
my $directory1 = "$bbs_file->{'data_directory'}_sendmail_${thread_moto}/";
my $file1 = "${directory1}${thread_number}_s.cgi";

# ���L���t�@�C�����J��
(%thread) = Mebius::BBS::thread({},$thread_moto,$thread_number);

	# �L���L�[���Ȃ��ꍇ
	if($thread{'keylevel'} < 1 && $type !~ /Cancel/){ return("���̋L���ɂ͓o�^�ł��܂���B"); }

		# ���L���̑��M�p�t�@�C�����J��
		open($thread_sendmail_handler,"<",$file1);
				if($type =~ /Renew/){ flock($thread_sendmail_handler,1); }
				while(<$thread_sendmail_handler>){
					chomp;
					my($address2) = split(/<>/);
						if($address2 eq $address){ $still_flag = "Still"; next; }
					push(@renewline_thread_sendmail,"$address2<>\n");
				}
		close($thread_sendmail_handler);

		# �������A�h���̃L�����A�t�@�C�����J��
		open($career_handler,"<","${main::int_dir}_address/$address_enc/bbs_thread_career.dat");
				if($type =~ /Renew/){ flock($career_handler,1); }
				while(<$career_handler>){
					chomp;
					my($no2,$moto2,$thread_subject_while,$bbs_title_while) = split(/<>/);
						if($no2 eq $thread_number && $moto2 eq $thread_moto){
							$still_flag = "Still";
							next;
						} else{
								if(!$thread_subject_while){
									my($thread) = Mebius::BBS::thread_state($no2,$moto2);
									$thread_subject_while = $thread->{'sub'};
								}
							push(@renewline_career,"$no2<>$moto2<>$thread_subject_while<>$bbs_title_while<>\n");
						}
				}
		close($career_handler);

		#�����o�^���ǂ������`�F�b�N
		if($type =~ /Still-check/){
			return($still_flag);
		}

		# ���o�^�폜����ꍇ
		if($type =~ /Cancel/){
				if(!$still_flag){ main::error("���̋L���ɂ͓o�^���Ȃ����A���ɉ�������Ă��܂��B"); }
		}

		# ���t�@�C���X�V
		if($type =~ /Renew/){

				# �V�����ǉ�����s
				if($type =~ /New-line/){ unshift(@renewline_thread_sendmail,"$address<>\n"); }

			# ���L���̔z�M�p�t�@�C�����X�V
			Mebius::Mkdir("",$directory1);
			Mebius::Fileout("Allow-empty",$file1,@renewline_thread_sendmail);

				# �V�����ǉ�����s
				if($type =~ /New-line/){ unshift(@renewline_career,"$thread_number<>$thread_moto<>$thread_subject<>$bbs_title<>\n"); }

			# �����A�h���̃L�����A�t�@�C�����X�V ( �f���L���p )
			#Mebius::Mkdir(undef,"${main::int_dir}_address");
			Mebius::Mkdir(undef,"${main::int_dir}_address/$address_enc");
			Mebius::Fileout("Allow-empty","${main::int_dir}_address/$address_enc/bbs_thread_career.dat",@renewline_career);

		}

		# ���L���̃n�b�V����Ԃ��ꍇ
		if($type =~ /Get-hash-thread/){ return(%thread); }

return();

}

#-----------------------------------------------------------
# �ҏW�t�H�[���Ȃ� ( bas_main.pl ��� )
#-----------------------------------------------------------
sub StartAddressForm{

# ���y�A����
$main::not_repair_url_flag = 1;
# �����悯
$main::noindex_flag = 1;

# ���[�h�U�蕪��
if($main::in{'type'} eq "cermail"){ &Cermail(undef,$main::in{'email'},$main::in{'char'}); }
elsif($main::in{'type'} eq "edit_address"){ edit_address_file(undef,$main::in{'email'},$main::in{'char'}); }
elsif($main::in{'type'} eq "form_edit_address"){ edit_address_form_view(undef,$main::in{'email'},$main::in{'char'}); }
else{ main::error("�y�[�W�����݂��܂���B[e1001]"); }
}


#-----------------------------------------------------------
# ���M�҂��֎~�i�m�F��ʁj
#-----------------------------------------------------------
sub edit_address_form_view{

# �Ǐ���
my($type,$address,$char) = @_;
my($line,$flag,$alert_line,$edit_type,$guide_message,$deny_sender_input,$edit_address_submit);
my $html = new Mebius::HTML;

# ���[���A�h���X�t�@�C�����擾
my(%address) = Mebius::Email::address_file("File-check Get-hash-detail",$address);

	# �e��G���[
	if($char eq ""){ main::error("���[���F�؃L�[���w�肵�Ă��������B"); }
	if($address{'cer_char'} eq "" && $address{'char'} eq ""){ main::error("���[���F�؃L�[���Ⴂ�܂��B"); }


	# ���y�F�؍ς݁z�̃A�h���X��ҏW����ꍇ
	if($address{'char'} eq $char){

		#�� �֎~�ς݂̏ꍇ
		$edit_type = "normal_deny";
		#$guide_message .= qq(����A���̃��[���A�h���X�ւ̑��M���ꊇ�֎~���܂��B);
		$edit_address_submit = qq(���̃��[���A�h���X ( $address{'address'} ) �ւ̑��M���~����);

	}

	# ���y�m�F�҂��z�̃A�h���X��ҏW����ꍇ
	elsif($address{'cer_char'} eq $char){
		$edit_type = "cer";
		$guide_message .= qq(<a href="http://$main::server_domain/">���r�E�X�����O</a> - $main::server_domain - ���<strong class="red">�o���̂Ȃ����[��</strong>���͂��܂����ꍇ�́A<br$main::xclose>);
		$guide_message .= qq(���萔�ł������[����j�����邩�A���̃y�[�W�ŋ֎~�ݒ�����肢���܂��B);
		$deny_sender_input = qq(<input type="checkbox" name="deny_sender" value="1" id="deny_sender"$main::parts{'checked'}$main::xclose> <label for="deny_sender">���[���𑗐M�������[�U�[���֎~����</label><br$main::xclose>);
			$edit_address_submit = qq(���̃��[���A�h���X ( $address{'address'} ) �ւ̑��M���~����);
			# �������g�����s�����ł��낤���[���̏ꍇ
			if($address{'cer_myaddress_flag'}){
				$alert_line = qq(<strong style="color:#f00;" >�������� �c ���Ȃ����g���֎~���悤�Ƃ��Ă���悤�ł��B�X�����ł����H</strong><br$main::xclose><br$main::xclose>);
			}

	}
	# ������ɂ������Ȃ��ꍇ
	else{ main::error("���[���F�؃L�[���Ⴂ�܂��B"); }


# �^�C�g����`
$main::sub_title = "���[���z�M�̋֎~�ݒ�";
$main::head_link3 .= qq(&gt; ���[����~);


# HTML
my $print = qq(<h1>���[�� �z�M�ݒ�</h1>);

$print .= qq(<div class="line-height">
$guide_message
$alert_line
<form action="$main::main_url" method="post"$main::sikibetu>);

$print .= $html->tag("h2","�z�M����");
$print .= send_email_hour_select_parts(\%address);


$print .= qq(<div>
<input type="hidden" name="mode" value="address"$main::xclose>
<input type="hidden" name="type" value="edit_address"$main::xclose>
<input type="hidden" name="edit_type" value="$edit_type"$main::xclose>
<input type="hidden" name="char" value="$char"$main::xclose>
<input type="hidden" name="email" value="$address{'address'}"$main::xclose>);


	if($address{'permanent_deny_flag'}){
		$print .= $html->tag("h2","�z�M�ĊJ",{ class => "green" });
		$print .= $html->input("checkbox","allow_send_email",1,{ text => "���̃��[���A�h���X ( $address{'address'} ) �ւ̔z�M���ĊJ����" });
	} else {
		$print .= $html->tag("h2","�z�M��~",{ class => "red" });
		$print .= qq(
		$deny_sender_input
		<input type="checkbox" name="deny_address" value="1" id="edit_address"$main::xclocse> <label for="edit_address">$edit_address_submit</label>
		<br$main::xclose><br$main::xclose>
		<strong style="color:#f00;" class="red">������A�{�T�C�g����́h�S�Ẵ��[���h���͂��Ȃ��Ȃ邽�߂����ӂ��������B</strong>
		);
	}

$print .= qq(
<input type="submit" value="���̓��e�ő��M����"$main::xclose class="block margin">
</div>
</form>
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}

#-----------------------------------------------------------
# �z�M����
#-----------------------------------------------------------
sub send_email_hour_select_parts{

my($line);
my $address_data = shift;
my($parts) = Mebius::Parts::HTML();

# �J�n����
$line .= qq(�z�M���F <select name="email_allow_hour_start">\n);
$line .= qq(<option>�Ȃ�</option>\n);
	for(0..23){ 
		my $selected = $parts->{'selected'} if($address_data->{'allow_hour_start'} eq $_);
		$line .= qq(<option value="$_"$selected>$_:00</option>\n);
	}
$line .= qq(</select> ����\n);

# �I������
$line .= qq(<select name="email_allow_hour_end">\n);
$line .= qq(<option>�Ȃ�</option>\n);
	for(0..23){ 
		my $selected = $parts->{'selected'} if($address_data->{'allow_hour_end'} eq $_);
		$line .= qq(<option value="$_"$selected>$_:59</option>\n);
	}
$line .= qq(</select> �܂�\n);
$line .= qq(�̃��[�����M��������\n);

$line;

}

#-----------------------------------------------------------
# ���M�҂��֎~�i���s�j
#-----------------------------------------------------------
sub edit_address_file{

# �錾
my($type,$address,$char) = @_;
my($edit_type,$success_message);
my($param) = Mebius::query_single_param();

# �����A�h�P�̃t�@�C�����擾
my(%address) = Mebius::Email::address_file("Get-hash File-check",$address);

	# �e��G���[
	if($char eq ""){ main::error("���[���F�؃L�[���w�肵�Ă��������B"); }
	if($address{'cer_char'} eq "" && $address{'char'} eq ""){ main::error("���[���F�؃L�[���Ⴂ�܂��B"); }

	# �^�C�v�U�蕪��
	if($address{'char'} eq $char){
		$edit_type = "normal";
		$success_message .= qq($address �ւ̃��[���z�M��S�Ē�~���܂����B<br$main::xclose>);
	}	elsif($address{'cer_char'} eq $char){
		$edit_type = "cer";
		$success_message .= qq($main::server_domain �̃T�[�o�[�ŋ֎~�ݒ�����܂����B<br$main::xclose>);
		#$success_message .= qq(���f�s�ׂ������ꍇ�́A���萔�ł���<a href="http://aurasoul.mb2.jp/etc/mail.html">���[���t�H�[��</a>�ł��A�����������i�T�C�g�Ǘ��҂Ɍq����܂��j�B);
	}	else{
		main::error("���[���F�؃L�[���Ⴂ�܂��B");
	}

	# ���M�҂̋֎~�t�@�C������������ - XIP / CNUMBER
	if($edit_type eq "cer" && $param->{'deny_sender'}){
		Mebius::Email::AccessCheck("Renew Deny",$address{'cer_xip'},$address{'cer_cnumber'});
	} elsif($param->{'allow_send_email'}){
			if(!$address{'permanent_deny_flag'}){ main::error("���̃��[���A�h���X�͔z�M��~����Ă��܂���B"); }
		Mebius::Email::address_file("Renew Allow-send",$address);
	# ���[���A�h���X�̋֎~�t�@�C������������
	} elsif($param->{'deny_address'}){
			if($address{'permanent_deny_flag'}){ main::error("���̃��[���A�h���X�́A���ɔz�M��~���ł��B"); }
		Mebius::Email::address_file("Renew Deny-send",$address);
	} elsif($param->{'email_allow_hour_start'} =~ /^[0-9]{1,2}$/ && $param->{'email_allow_hour_end'} =~ /^[0-9]{1,2}$/){

		my %renew;
		$renew{'allow_hour'} = "$param->{'email_allow_hour_start'}-$param->{'email_allow_hour_end'}";
		Mebius::Email::address_file("Renew",$address,%renew);
	} else {
		Mebius->error("�������s���܂���ł����B");
	}


# �^�C�g����`
$main::sub_title = "���[���z�M�ݒ�";
$main::head_link3 .= qq(&gt; ���[���z�M�ݒ�);


# HTML
my $print = <<"EOM";
<div class="line-height">
���s���܂����B
</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}


#-----------------------------------------------------------
# ���M�֎~��IP/�Ǘ��ԍ�
#-----------------------------------------------------------
sub AccessCheck{

# �錾
my($type,$xip,$cnumber) = @_;
my($error_flag,$deny_handler_xip,$deny_handler_cnumber);
my($share_directory) = Mebius::share_directory_path();
my $time = time;

# �����`�F�b�N
my $file_cnumber = $cnumber;
$file_cnumber =~ s/\W//g;
my($xip_enc) = Mebius::Encode(undef,$xip);

	# ���f��񂪂���ꍇ ( XIP )
	if($xip_enc){
		open($deny_handler_xip,"<","${share_directory}_ip/_ip_denycermail_xip/${xip_enc}.cgi");
			if($type =~ /Renew/){ flock($deny_handler_xip,1); }
		chomp(my $top1_xip = <$deny_handler_xip>);
		my($oktime1) = split(/<>/,$top1_xip);
			if($oktime1 && $main::time < $oktime1){
				$error_flag = qq("���f�s�ׂ̕񍐂ɂ��A���m�点���[����z�M�ł��܂���B");
			}
		close($deny_handler_xip);
	}

	# ���f��񂪂���ꍇ ( Cookie�ɂ�� )
	if($file_cnumber){
		open($deny_handler_cnumber,"<","${share_directory}_ip/_ip_denycermail_cnumber/$file_cnumber.cgi");
			if($type =~ /Renew/){ flock($deny_handler_cnumber,1); }
		chomp(my $top1_cnumber = <$deny_handler_cnumber>);
		my($oktime2) = split(/<>/,$top1_cnumber);
			if($oktime2 && $main::time < $oktime2){
				$error_flag = qq("���f�s�ׂ̕񍐂ɂ��A���m�点���[����z�M�ł��܂���B");
			}
		close($deny_handler_cnumber);
	}

	# �t�@�C�����X�V
	if($type =~ /Renew/){
			# �V�K��������ꍇ
			if($type =~ /Deny/){
				my $allowtime = $time + 365*24*60*60;
				my $renew_line .= qq($time<>\n);
					if($xip_enc){ Mebius::Fileout(undef,"${share_directory}_ip/_ip_denycermail_xip/${xip_enc}.cgi",$renew_line); }
					if($file_cnumber){ Mebius::Fileout(undef,"${share_directory}_ip/_ip_denycermail_cnumber/$file_cnumber.cgi",$renew_line); }
			}
	}


return($error_flag);

}

1;

