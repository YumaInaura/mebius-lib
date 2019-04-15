
use strict;
package Mebius::Login;

#-----------------------------------------------------------
# �����o�[���̃��O�C���`�F�b�N
#-----------------------------------------------------------
sub Logincheck{

# �錾
my($type,$secret_moto) = @_;
my(@set_cookie,$session_handler);
my($top1,$username,$password,$input_username,$input_password,$session,$top_member1,$logined_flag);
my($cookie_username,$cookie_session);
my($session_encpassword,$session_salt);


	#�A�N�Z�X�U�蕪��
	if($main::device_type eq "mobile"){ main::kget_items(); }

	# �ڑ����𔻒�
	if(!$main::host){
		my($gethost) = Mebius::GetHostByFile();
		$main::host = $gethost;
	}
	if(length($main::host) < 6){ main::error("�z�X�g�����擾�ł��܂���B"); }
	if($main::bot_access){ main::error("�y�[�W�����݂��܂���B"); }
	$main::noindex_flag = 1;

	# ��{�v�f���`
	$secret_moto =~ s/\W//g;
	if($secret_moto eq ""){ main::error("�w�肪�ςł��B"); }

	# �N�b�L�[���e����Z�b�V�����t�@�C�����J���ă��O�C���`�F�b�N
	($logined_flag) = &Loginsession("Logincheck",$secret_moto);

	# ���A�J�E���g���A�p�X���[�h���͂�����ꍇ�̏���
	if(!$logined_flag && $main::in{'colol'}){

		$input_username = $main::in{'connent'};
		$input_password = $main::in{'hamdle'};
			if($input_username =~ /\W/){ main::error("���[�U�[���ɂ͔��p�p�����̂ݎg���܂��B"); }
			if($input_username eq ""){ main::error("���[�U�[������͂��Ă��������B"); }
			if($input_password eq ""){ main::error("�p�X���[�h����͂��Ă��������B"); }

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($input_username,$input_password)); }

		($logined_flag) = &Memberfile("Passcheck Input",$secret_moto,$input_username,$input_password);

	}


# ���O�C�������s�����ꍇ�A���O�C����ʂ�\������
# main::access_log("ALL-MISSED-LOGINCHECK","���O�C���̎��s"); 
if(!$logined_flag){ &Loginview("",$secret_moto); }

# �摜��\������
if($main::in{'mode'} eq "image"){ Mebius::Login::Image("",$secret_moto,"$main::in{'file'}"); }

# Docomo�̌ő̎��ʔԍ��Ή�
if($main::k_access eq "DOCOMO"){ $main::utn2 = qq( utn="utn"); }

}


#-----------------------------------------------------------
# �Z�b�V�����t�@�C���̑���
#-----------------------------------------------------------
sub Loginsession{


# �錾
my($type,$secret_moto) = @_;
my(undef,undef,$input_username,$input_password,$memory_salt) = @_ if($type =~ /New/);
my($cookie_username,$session_name,$user_name);
my($session_handler,$top1,$encpassword,$sessionfile,$renewline);
my($tkey,$tencpassword,$tsalt,$tlasttime,$tlimittime,$tusername,$logined_flag,$plustype_setcookie);

	# �����`�F�b�N�P
	$secret_moto =~ s/\W//g;
	if($secret_moto eq ""){ return(); }

	# �Z�b�V�����l���`�i���O�C���`�F�b�N�p�j
	if($type =~ /Logincheck/){

		# ���O�C���p�̓Ǝ��N�b�L�[���擾
		my($cookie) = Mebius::get_cookie("Acret-$secret_moto");
		($cookie_username,$session_name) = @$cookie;
		$cookie_username =~ s/\W//g;
		$session_name =~ s/\W//g;
		($user_name) = ($cookie_username);
	}

	# �Z�b�V�����l���`�i�V�K�쐬�p�j
	if($type =~ /New/){
		$input_username =~ s/\W//g;
			if($input_username eq ""){ return(); }
			if($input_password eq ""){ return(); }
		my @charpass = ('a'..'z', 'A'..'Z', '0'..'9');
		for(1..20){ $session_name .= $charpass[int(rand(@charpass))]; }
	}

	# �ő̎��ʔԍ�����Z�b�V�����l���`
	if($main::kaccess_one){
			if($main::k_access eq "DOCOMO" && $main::realcookie){ } # Docomo��Cookie������ꍇ�͌ő̎��ʔԍ����g��Ȃ�
			else{ $session_name = $main::agent; }
	}

	# �Z�b�V�������G���R�[�h
	($session_name) = Mebius::Encode("",$session_name);
	if($session_name eq ""){ return(); }

# �t�@�C����`
$sessionfile = qq(${main::int_dir}_member/_sessions/_${secret_moto}_session/${session_name}_session.dat);

	# ���O�I�t����ꍇ
	if($main::in{'mode'} eq "logoff"){ 
		Mebius::set_cookie("Acret-$secret_moto");
		unlink($sessionfile); 
	}

	# ���Z�b�V�������Q�b�g����ꍇ
	if($type =~ /Logincheck/){

		# �Z�b�V�����t�@�C�����J��
		my $open = open($session_handler,"<",$sessionfile);
		chomp($top1 = <$session_handler>);
		($tkey,$tencpassword,$tsalt,$tlasttime,$tlimittime,$tusername) = split(/<>/,$top1);
		close($session_handler);

			# ���O�C���`�F�b�N�̏ꍇ�A���݂��Ȃ��Z�b�V�������̓A�^�b�N�Ƃ��ċL�^����
			if($type !~ /New/){
					if(!$open){	Mebius::AccessLog(undef,"ATACKED-LOGINCHECK","���݂��Ȃ��Z�b�V������ $session_name"); }
			}

			# �L�[�������̏ꍇ�A���^�[��
			if(!$tkey){ return(); }

			# �L���������؂�Ă���ꍇ�A���^�[��
			#if($main::postflag){ $tlimittime += 60*60; }
			#if($main::time > $tlimittime){ return(); }

			# �N�b�L�[���Ȃ��A�Z�b�V�����t�@�C�����̃A�J�E���g�����g���ꍇ
			if($tusername){ $user_name = $tusername; }

			# ���̂܂܃p�X���[�h�`�F�b�N
			($logined_flag) = &Memberfile("Session",$secret_moto,$user_name,$tencpassword,$tsalt);

			# ����Ƀ��^�[��
			return($logined_flag);
	}

	# ���Z�b�V������V�K�쐬����i���͏����B���̑O�̏����ŁA�����o�[�t�@�C�����J���ăp�X���[�h����v�����ꍇ�j
	if($type =~ /New/){

		# �p�X���[�h�𕡍���
		my($newencpassword,$newsalt) = Mebius::Crypt::crypt_text("MD5",$input_password,$memory_salt);

		# �ő厞�Ԃ��`
		$tlimittime = time + 365*24*60*60;

		# �V�����������ލs
		$renewline .= qq(1<>$newencpassword<>$newsalt<>$main::time<>$tlimittime<>$input_username<>\n);
		$renewline .= qq($main::addr<>$main::host<>$main::agent<>\n);

		# �t�@�C�����쐬
		Mebius::Fileout("",$sessionfile,$renewline);

		# �Z�b�V�������N�b�L�[�ɃZ�b�g
		Mebius::set_cookie("Acret-$secret_moto",[$input_username,$session_name]);
	}

}

#-----------------------------------------------------------
# �����o�[�t�@�C�����J��
#-----------------------------------------------------------
sub Memberfile{

# �錾
my($type,$secret_moto,$input_username,$input_password) = @_;
my(undef,undef,$user_name,$session_encpassword,$session_salt) = @_ if($type =~ /Session/);
my($logined_flag,$member_handler,$top1,$encpassword,$memory_salt);
my($memberfile);

# �t�@�C����`
$memberfile = qq(${main::int_dir}_member/${secret_moto}_member.log);


# �����o�[�t�@�C�����J��
open($member_handler,"<",$memberfile);

# �g�b�v�f�[�^�𕪉�
chomp($top1 = <$member_handler>);
my($tkey) = split(/<>/,$top1);

	# �t�@�C����W�J����
	while(<$member_handler>){

		chomp;
		my($key2,$level2,$username2,$encpassword2,$salt2) = split(/<>/,$_);

			# ���Z�b�V�����Ń��O�C������ 
			if($type =~ /Session/ && $username2 && $username2 eq $user_name){

				# �p�X���[�h����v�����ꍇ
				if($encpassword2 && $salt2 && "$encpassword2-$salt2" eq "$session_encpassword-$session_salt"){
					$main::username = $username2;
					$logined_flag = 1;
				}

			}

			# �����͏�񂩂烍�O�C������
			elsif($type =~ /Input/ && $username2 && $username2 eq $input_username){

				# �p�X���[�h�𕡍���
				my($encpassword,$salt) = Mebius::Crypt::crypt_text("MD5",$input_password,$salt2);

#	if(Mebius::alocal_judge() && $type =~ /Input/){ Mebius::Debug::Error(qq($username2 eq $input_username / $encpassword2 eq $encpassword)); }

				# �p�X���[�h����v�����ꍇ
				if($encpassword2 && $encpassword2 eq $encpassword){
					$logined_flag = 1;
					$main::username = $username2;
					$memory_salt = $salt2;
				}

			}
	}
close($member_handler);

	# ���Z�b�V�����t�@�C������`�F�b�N�����ꍇ
	if($type =~ /Session/){

			# ���O�C������
			if($logined_flag){
				main::access_log("SUCCESSED-LOGINCHECK","�Z�b�V��������̃��O�C������");
			}

			# ���O�C�����s
			else{
				main::access_log("ATACKED-LOGINCHECK","�Z�b�V�����͑��݂��邪���O�C�����s");
			}
	}

	# �����͏�񂩂�`�F�b�N�����ꍇ
	if($type =~ /Input/){
	
			# ���O�C������
			if($logined_flag){

				# ���O�C�������̃��O�����
				main::access_log("SUCCESSED-LOGINCHECK","�����͂̐���");

				# �Z�b�V�����t�@�C�����쐬
				&Loginsession("New",$secret_moto,$input_username,$input_password,$memory_salt);
			}


			# ���O�C�����s
			else{

				# ���O�C�����s�̃��O�����
				main::access_log("MISSED-LOGINCHECK","�����͂̎��s");

				# �A�J�E���g���̂݃N�b�L�[���Z�b�g
				Mebius::set_cookie("Acret-$secret_moto",[$input_username]);

				# ���O�C����ʂɈȍ~
				&Loginview("Error",$secret_moto,"�A�J�E���g���A�܂��̓p�X���[�h���Ԉ���Ă��܂��B");

			}

	}
# ���^�[��
return($logined_flag);

}

#-----------------------------------------------------------
# �摜��\������
#-----------------------------------------------------------
sub Image{

# �錾
my($type,$secret_moto,$image) = @_;
my($imagehandler,$imagefile);

# �����`�F�b�N
my($filename,$tail) = split(/\./,$image);
$filename =~ s/[^\w-]//g;
$tail =~ s/\W//g;
	if($filename eq ""){ main::error("�t�@�C�������w�肵�Ă��������B"); }
	if($tail eq ""){ main::error("�g���q���w�肵�Ă��������B"); }

# �t�@�C����`
$imagefile = "${main::int_dir}_upload/_${secret_moto}_upload/$filename.$tail";

	# �t�@�C�������݂��Ȃ��ꍇ
	if(!-e $imagefile){ main::error("�摜�����݂��܂���B"); }

	# �w�b�_
	if($tail eq "png"){ print "Content-type: image/png\n\n"; }
	elsif($tail eq "gif"){  print "Content-type: image/png\n\n"; }
	elsif($tail eq "jpeg" || $tail eq "jpg"){  print "Content-type: image/jpeg\n\n"; }
	else{ main::error("�t�@�C���`�����ςł��B"); }

# �摜���o��
open $imagehandler,$imagefile;
binmode ($imagehandler);
print <$imagehandler>;
close ($imagehandler); 

exit;


}


#-----------------------------------------------------------
# ���O�C����ʂ�\��
#-----------------------------------------------------------
sub Loginview{

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$secret_moto,$error_message) = @_;
my($first_username,$cookie_username,$docomo_navilink);

# ���O�C���p�̓Ǝ��N�b�L�[���擾
my($cookie) = main::get_cookie("Acret-$secret_moto");
($cookie_username) = @$cookie;

# �^�C�g����`
$main::sub_title = qq(���O�C��);
$main::head_link2 = qq( &gt; ���O�C��);

# ��������
if($main::in{'mode'} eq "logoff"){ $first_username = ""; }
elsif($main::in{'connent'}){ $first_username = $main::in{'connent'}; }
elsif($cookie_username){ $first_username = $cookie_username; }
$first_username =~ s/\W//g;

	# Docomo �Ή��̃i�r�Q�[�V���������N
	if($main::k_access eq "DOCOMO"){
		$docomo_navilink = qq(<br$main::xclose>*Docomo�Ŏ������O�C������ꍇ��<a href="./"$main::sikibetu>�ő̎��ʔԍ��𑗐M</a>���Ă��������B\(����̓��[�U�[��/�p�X���[�h�����\));
	}

# �G���[���b�Z�[�W
if($error_message){ $error_message = qq(<span style="color:#f00;font-size:small">��$error_message</span>); }

# CSS��`
$main::css_text .= qq(
form.login{margin:1em 0em;}
);



# HTML
my $print = qq(
<h1$main::kfontsize_midium>���O�C��</h1>
$error_message
<form action="./" method="post" class="login"$main::sikibetu>
<div>
<input type="hidden" name="mode" value=""$main::xclose>
���[�U�[�� <input type="text" name="connent" value="$first_username" size="10"><br$main::xclose>
�p�X���[�h <input type="password" name="hamdle" value="" size="10"><br$main::xclose>
<input type="submit" name="colol" value="���O�C������"$main::xclose>
<label><input type="checkbox" name="memory" value="1"$main::parts{'checked'}><span class="guide">���O�C�����L������</span></label>
<input type="hidden" name="moto" value="$main::realmoto"$main::xclose>
<input type="hidden" name="backurl" value="http://$main::server_domain$main::requri"$main::xclose><br$main::xclose><br$main::xclose>
<span class="guide">�����O�C���������ς��܂������A�p�X���[�h�͓����ł��B�p�X���[�h��Y�ꂽ�ꍇ�A���܂������Ȃ��ꍇ��<a href="mailto:$basic_init->{'admin_email'}">�Ǘ���</a>�܂Ŗ₢���킹�Ă��������B</span>
$docomo_navilink
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

1;

