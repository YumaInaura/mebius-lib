

#-----------------------------------------------------------
# ��{�ݒ�
#-----------------------------------------------------------
sub scbase{

# �Ǐ���
my($line,$i,$flag);
our($alocal_mode,%bbs);

# CSS��`
$css_text .= qq(
span.turn{background-color:#dee;font-size:80%;padding:0.3em 0.7em;}
img.noborder{border-style:none;}
);

	# ���[�U�[�����擾
	if(!$admin_mode && !$username){
		if($alocal_mode){ $username = "aura"; }
		else{ $username = $ENV{'REMOTE_USER'} || $ENV{'REDIRECT_REMOTE_USER'}; }
			#my $line;
			#foreach(keys %ENV){
			#	$line .= qq($_ ;$ENV{$_}<br>);
			#}
		if($username eq ""){ main::error("���[�U�[�����w�肳��Ă��܂���B"); }
	}

# �ݒ�t�@�C����ǂݍ���
open(FILE_IN,"<","${int_dir}_invite/init_${secret_mode}.cgi");
my $top_init1 = <FILE_IN>; chomp $top_init1;
my $top_init2 = <FILE_IN>; chomp $top_init2;
my $top_init3 = <FILE_IN>; chomp $top_init3;
close(FILE_IN);

# �ݒ�t�@�C��������
($title,$allowurl_mode,$allowaddress_mode,$fastpost_mode,$freepost_mode,$candel_mode) = split(/<>/,$top_init1);
($norank_wait,$style,$setumei) = split(/<>/,$top_init2);
($scad_email,$scad_name) = split(/<>/,$top_init3);

$bbs{'setumei'} = $setumei;

# �l���Ȃ��ꍇ
if($style eq ""){ $style = "blue1"; }

# �ݒ�l�𐮌`
($head_title) = $title;
if($style){ $style = qq(/style/$style.css); }

# �K�{�ݒ�
our $noads_mode = 1;
$concept .= qq( NOT-PV NOT-KR NOT-NEWS NOT-ADS NOT-SUPPORT MODE-SECRET);
$bbs{'concept'} = $concept;
our $noindex_flag = 1;
our $new_min_msg = 10;
our $min_msg = 2;

# �Y�t�t�@�C���̍ő�o�C�g�� ( KB )
$upload_maxkbyte = 5000;

# �l�̒���
$scmoto = $moto;
$scmoto =~ s/^sc//g;

	# �������Cookie���`
	if(!$admin_mode){
		my(@csecret,$flag);
			foreach(split(/ /,$csecret)){
			if($_ eq $scmoto){ $flag = 1; }
			push(@csecret,$_);
			}
			if(!$flag){ push(@csecret,$scmoto); }
		$csecret = "@csecret";
	}

# �A�N�Z�X���������
#if(!$admin_mode){ &secret_push_accesslog(); }

# �����̐ݒ���擾����
if(!$admin_mode){ &get_scmyfile(); }
}


#-----------------------------------------------------------
# �A�N�Z�X���������
#-----------------------------------------------------------
sub secret_push_accesslog{

# �Ǐ���
my($line);

# �A�N�Z�X�����ɒǉ�����s
$line .= qq($time<>$username<>$addr<>$agent<>$chandle<>$pmfile<>\n);

# �A�N�Z�X�������J��
open(IN,"<","${int_dir}_invite/access_${secret_mode}.cgi");
	while(<IN>){
		$i++;
			if($i < 500){ $line .= $_; }
	}
close(IN);

# �A�N�Z�X�������X�V
open(FILE_OUT,">","${int_dir}_invite/access_${secret_mode}.cgi");
print FILE_OUT $line;
close(FILE_OUT);
Mebius::Chmod(undef,"${int_dir}_invite/access_${secret_mode}.cgi");

}

#-----------------------------------------------------------
# �����̐ݒ���擾
#-----------------------------------------------------------
sub get_scmyfile{

# �����o�[�t�@�C�����J��
open(MEMBER_IN,"<","${int_dir}_invite/member_${secret_mode}.cgi");
while(<MEMBER_IN>){
chomp;
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
if($user eq $username){ ($scmy_key,$scmy_handle,$scmy_email,$scmy_emailkey,$scmy_sendmail) = ($key,$handle,$email,$emailkey,$sendmail); }
}
close(MEMBER_IN);

# ���[���A�h���X���Ȃ��ꍇ
	#if($scmy_email eq "" && $in{'mode'} ne "member" && !$main::alocal_mode){ &error("$title�ւ悤�����I ���̌f���𗘗p����ɂ́A�܂�<a href=\"$script?mode=member&amp;type=vedit\">���Ȃ��̃��[���A�h���X��ݒ�</a>���Ă��������B�i<a href=\"mailto:$scad_email\">�Ǘ��҂ɘA��</a>�j","none"); }

}


use strict;

#-----------------------------------------------------------
# ���m�点���[���𑗐M - strict
#-----------------------------------------------------------

sub sendmail_scres{

# �Ǐ���
my($type,$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com) = @_;
my($body1,$body2,$subject,$text,$text_length,$timeout_flag);
our($realmoto,$alocal_mode,$allowaddress_mode,$secret_mode,$head_title);
our($server_domain,$myadmin_flag,$int_dir,$username,$scmy_email);

if($alocal_mode){ $allowaddress_mode = 1; }

# ���^�[��
if(!$allowaddress_mode){ return; }
if(!$secret_mode){ return; }

	# �{���̏ȗ�
	foreach( split(/<br>/,$i_com) ){
			if($text_length < 50){ $text .= qq(${_} ); }
		$text_length += length $_;
	}


# ����
$subject = qq(�u$i_sub�v�� $i_handle���� �����e���܂���);

# �m�[�}���̕���
$body1 = qq(���r�E�X�����O�́y$head_title�z�ɍX�V���������̂ŁA���m�点�������܂��B

��$i_handle > $text �c

��$i_sub - $head_title
  http://$server_domain/_$realmoto/$i_postnumber.html

�����X��\\��
  http://$server_domain/_$realmoto/$i_postnumber.html#S$i_resnumber
);

# �V���v���ȕ���
$body2 = qq(http://$server_domain/_$realmoto/$i_postnumber.html
);

# �z�M�p�t�@�C�����J��
open(SEND_IN,"<","${int_dir}_invite/member_${secret_mode}.cgi");
while(<SEND_IN>){
chomp;
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
my($body);

if(!$sendmail || $email eq ""){ next; }
elsif($sendmail eq "1"){ $body = $body1; }
elsif($sendmail eq "2") { $body = $body2; }

$body .= qq(\n�����o�[�ݒ�F\nhttp://$server_domain/_$moto/?mode=member&type=vedit);

# �����̃��X�̏ꍇ
if(!$myadmin_flag && ($user eq $username || $email eq $scmy_email)){ next; }

# ���[�����M
if($timeout_flag){ last; }
if($email ne ""){ Mebius::send_email(undef,$email,$subject,$body); }

}
close(SEND_IN);

}



1;

