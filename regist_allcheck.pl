
# ��{�錾
use Mebius::Echeck;
use Mebius::RegistCheck;
use Mebius::Getstatus;
use Mebius::Text;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �薼�̃`�F�b�N
#-----------------------------------------------------------
sub subject_check{

# �錾
my($type,$subject,$category,$concept) = @_;
my($check_subject);
my($alert_flag,$error_flag,$long_length,$short_length,$bad_keyword);
our($e_com,$a_com,$delete_url);

# �薼����{�ϊ�
($subject) = &base_change($subject);

	# ���s�𑦍��֎~
	if($subject =~ /<br>/){ main::error("�薼�ł͉��s�ł��܂���B"); }

	# �ُ�Ȓ����̑薼�𑦍��֎~
	if(length($subject) > 1000){ main::error("�薼���������܂��B"); }

# �薼�̒������擾
($long_length,$short_length) = &get_length("",$subject);

# �`�F�b�N�p�ɑ薼���G�X�P�[�v
$check_subject = Mebius::escape("Space",$subject);

# URL�`�F�b�N
if($check_subject =~ m!(ttp|://|\.com|\.jp|\.net)!){ $e_com .= qq(���薼�ɂt�q�k�͎g���܂���B); }

	# �薼�̒����`�F�b�N
	if($type !~ /Empty/ && ($check_subject eq "" || $check_subject =~ /^(\x81\x40|\s|<br>)+$/)){ $e_com .= qq(���薼���󔒁A�܂��͋L�������ł��B<br>); }
	elsif($long_length > 25){ $e_com .= qq(���薼���������܂��B�i �S�p $long_length���� / 25���� �j<br>); }
	elsif($type !~ /Empty/ && $short_length < 1){ $e_com .= qq(���薼���Z�����܂��B<br>); }

# �n�샂�[�h�ł͑薼���`�F�b�N���Ȃ�
#if($type =~ /Sousaku/ && $category ne "diary"){ return($subject); }

	# �薼���`�F�b�N�i�G���[�p�j
	if($check_subject =~ /(��|�L|�C|��)(��|�`|�n)(����|�K�C|�Q|�O)/){ $error_flag = qq(evil); }
	if($check_subject =~ /(��؂�)/){ $error_flag = qq(sex); }

	# �薼���`�F�b�N�i�A���[�g�p�j
	if($check_subject =~ /(���J|�ނ�|�C��|����)(�c�N|��|����)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(�C��|����|��|��)(����)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(�C���C��|���炢��|�ՁX|�Չ�)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(��|�E) ( (��|�U)(��|�C|����) | (��|\Q�[\E)(��|��|�G|�F) ) /x){ $alert_flag = qq(evil); }
	if($check_subject =~ /�L��(�C|�B|��|��)|\Q�Ӳ\E/x){ $alert_flag = qq(evil); }
	if($check_subject =~ /(UZEEE|������|�E�b�U|��������)/x){ $alert_flag = qq(evil); }
	if($check_subject =~ /(�~|���h([^��]|$)|�ň�|(����)(������|����))|(��)?����(��|��|���)(��|����)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(�܌�����|���邳��|��)/){ $alert_flag = qq(evil); }
	if($check_subject =~ /(�c��|�G�b�`)/){ $alert_flag = qq(sex); }
	if($check_subject =~ /(����)/){ $alert_flag = qq(private); }
	if($check_subject =~ /(�r�炵)/){ $alert_flag = qq(reverse); }
	if($check_subject =~ /(����|�ގ�|�ޏ�)/ && $check_subject =~ /(��W)/){ $alert_flag = qq(deromance); }
	if($check_subject =~ /(��s|�O�`)/){ $alert_flag = qq(gutty); }
	if($check_subject =~ /(�N���b�N)/){ $error_flag = qq(fuse); $bad_keyword = $1; }

	# �G���[�t���O������ꍇ
	if($error_flag eq "fuse"){
		$e_com .= qq(���薼�ɂ��̃L�[���[�h ( $bad_keyword ) �͎g���܂���B ��̓I�ȑ薼�����Ă��������B<br>);
	}

	elsif($error_flag){
		$e_com .= qq(�����̑薼�͏������߂܂���B�@���p��̃}�i�[�ɂ��z�����������B<br>);
	}

	# �t���O������ꍇ
	elsif($alert_flag eq "evil"){
		$a_com .= qq(���薼�`�F�b�N - �}�i�[��������\�\\��\������܂��񂩁H�@���e���e�ɂ͏\\��\���z�����������B<br>);
	}
	
	# �t���O������ꍇ
	elsif($alert_flag eq "sex"){
		$a_com .= qq(���薼�`�F�b�N - ���I�ȓ��e��A���������������������˂Ȃ����e���܂܂�Ă��܂��񂩁H�i�l�^�A��k�ȂǊ܂ށj�@���p��̃}�i�[�ɂ��z�����������B<br>);
	}
	# �t���O������ꍇ
	elsif($alert_flag eq "private"){
		$a_com .= qq(���薼�`�F�b�N - �l���̌��������悤�Ƃ��Ă��܂��񂩁H�@�l���͐�΂Ɉ���Ȃ��ł��������B<br>);
	}
	# �t���O������ꍇ
	elsif($alert_flag eq "gutty" && $concept !~ /Sousaku/){
		$a_com .= qq(���薼�`�F�b�N - ��s�͕K�������֎~�ł͂���܂��񂪁A<strong>�u�������v�u���ˁv</strong>�Ȃǂ�\�\\�����������܂Ȃ��悤�A���肢�������܂��B<br>);
	}
	
	# �t���O������ꍇ
	elsif($alert_flag eq "reverse" && $concept !~ /Sousaku/){
		$a_com .= qq(���薼�`�F�b�N - �r�炵�s�ׂ֔������Ȃ����Ă��܂��񂩁H�@�r�炵�ɂ�<a href="$delete_url">�폜�˗�</a>�����肢���܂��B<br>);
	}
	# �t���O������ꍇ
	elsif($alert_flag eq "deromance" && $concept !~ /Sousaku/){
		$a_com .= qq(���薼�`�F�b�N - �{�T�C�g�ł́u���l��W�v�u���ʑ����W�v�Ȃǂ̏o��n���p�͏o���܂���B�B<br>);
	}


	# �G���[/�A���[�g���L�^
	if($error_flag){
		 Mebius::Echeck::Record("","Subject","�薼�F $subject");
	}

	elsif($alert_flag){
		Mebius::Echeck::Record("","Subject","�薼�F $subject");
		$main::alert_type .= qq( �薼);
	}

# ���^�[��
return($subject,$error_flag,$alert_flag);

}

use strict;

#-----------------------------------------------------------
# �������`�F�b�N
#-----------------------------------------------------------
sub length_check{

# �錾
my($check,$name,$max,$mini) = @_;
my $length = int(length($check) / 2);
our($e_com);

	if($max && $length > $max){ $e_com .= qq(��$name���������܂��B�i ����$length���� / �ő�$max���� �j<br>); }
	if($mini && $length < $mini){ $e_com .= qq(��$name���Z�����܂��B�i ����$length���� / �ŏ�$mini���� �j<br>); }

	if($mini >= 1 && ($check eq "" || $check =~ /^(\x81\x40|\s|<br>)+$/)){ $e_com .= qq(��$name����͂��Ă��������B<br>); }

}


#-----------------------------------------------------------
# �{���̕������v�Z
#-----------------------------------------------------------
sub get_length{

# �錾
my($type,$check) = @_;
my($long_length,$short_length,$spacenum,$halfnum,$length1,$length2,$decration_length,$kasegi_length);

# �����������̌v�Z
$long_length = int(length($check) / 2);

	# �f�R���[�V�����ʂ𔻒�
	foreach(split(/<br>/,$check)){

		# �Ǐ���
		my($text2) = ($_);
		my($empty_length);

		# URL������
		($text2) = Mebius::url({ EraseURL => 1 },$text2);

		# �X�^���v����������
		($text2) = Mebius::Stamp::erase_code($text2);

			# �i���o�[�����N�̓G�X�P�[�v���Ȃ� 
			if($text2 =~ /^(\s+)?(&gt;|��)(&gt;|��)(\d+)/){
				0;
			# ���p�����̓G�X�P�[�v
			} elsif($text2 =~ /^(\s+)?(&gt;|��)/){
				next;
			}

			# ���̃G�X�P�[�v
			if($text2 =~ /�{���͑S�p(\d+)�����ȏ�������Ă�������/){ next; }
			if($text2 =~ /�{���̕����������Ȃ����܂�/){ next; }

		$text2 =~ s/(�@| )//g;
		$text2 =~ s/((����|����|����)(��)?((��|����)��)?){2,}//g;

		$decration_length += ($text2 =~ s/(&apos;|&quot;)/$&/g) * (3.0  - 0.5);	# ���ƂŔ��肷�� ; ���d���J�E���g���Ȃ��悤��
		$decration_length += ($text2 =~ s/(&#39;|&amp;)/$&/g) * (2.5 - 0.5 );	# ���ƂŔ��肷�� ; ���d���J�E���g���Ȃ��悤��
		$decration_length += ($text2 =~ s/(&gt;|&lt;)/$&/g) * (2.0 - 0.5);		# ���ƂŔ��肷�� ; ���d���J�E���g���Ȃ��悤��
		$decration_length += ($text2 =~ s/(\.|,|w|!|\?){2}/$&/g);
		$decration_length += ($text2 =~ s/(��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|�O|�Z|��|��|��|��|��|��)/$&/g);
		$decration_length += ($text2 =~ s/(��|��|�{|��|��|��|��|�P|�Q|�\\|�E|�c|\Q�|\E)/$&/g);

		$decration_length += ($text2 =~ s/(��|��|�R|��|��|��|��|��|��|�D|�M|�L|�_)/$&/g);
		$decration_length += ($text2 =~ s/(�C)/$&/g);
		$decration_length += ( ($text2 =~ s/(�B|�A|��|�I|�H|�`|\Q�[\E){2}/$&/g) * 2 );
		$decration_length += ( ($text2 =~ s/(\*|-|\+|_|=|:|;|�|�|\/|\(|\)|\^|\~|`)/$&/g) * 0.5 );

		$kasegi_length += ( ($text2 =~ s/(��|��|��|��|��){5}/$&/g)*5 );


		$short_length += length($text2);

	}


	# �Z�����̕��������v�Z
	$short_length = int($short_length/2);

	# ���������������ꍇ
	if($type =~ /Decoration-cut/ && $decration_length){ $short_length -= $decration_length; }
	if($type =~ /Decoration-cut/ && $decration_length){ $short_length -= $kasegi_length; }

	# ����
	if($short_length <= 0){ $short_length = 0; }

# �����ɂ���
$short_length = int $short_length;
$long_length = int $long_length;

# ���^�[��
return($long_length,$short_length,$decration_length);

}



#-------------------------------------------------
# �O���̂t�q�k�C�A�h���X�`�F�b�N
#-------------------------------------------------
sub url_check{

my $regist = new Mebius::Regist;
my $error = $regist->url_check($_[1],$_[0]);

	if($error){ 
		shift_jis($error);
		$main::e_com .= $error;
	}

}


no strict;

#-----------------------------------------------------------
# ��{�ϊ�
#-----------------------------------------------------------
sub base_change{

# �錾
my($check,$mode) = @_;
my($return_check,$hit,$comment_split);
our($realmoto,$concept);

# ���P�s���ɑ΂��鏈��

	# ���͂����s�œW�J
	foreach $comment_split (split(/<br>/,$check,-1)){

		# �L���݂̂̍s�̓G�X�P�[�v
		if($comment_split =~ /^(\.|,)$/){ next; }

		# �A���������p�X�y�[�X���폜
		$comment_split =~ s/\s+/ /g;

			# �A�������S�p�X�y�[�X���폜
			if($main::bbs{'concept'} !~ /Sousaku-mode/){
				$comment_split =~ s/((�@|\s){8,})/�@�@�@�@�@�@�@�@/g;
			}

			# �g�єł��瓊�e����ꍇ
			if($main::kflag){
				$comment_split =~ s/^(�@|\s){2,}/�@�@/g;
				$comment_split =~ s/(�@|\s){2,}/�@�@/g;
			}

		# �S�p�L���̗����Z�k
		if($concept !~ /Sousaku/){
			$comment_split =~ s/(�`){15,}/�`�`�`�`�`�`�`�`�`�`�`�`�`�`�`/g;
			$comment_split =~ s/(��){15,}/������������������������������/g;
			$comment_split =~ s/(��){15,}/������������������������������/g;
			$comment_split =~ s/(��){15,}/������������������������������/g;
			$comment_split =~ s/(��){15,}/������������������������������/g;
			$comment_split =~ s/(��){15,}/������������������������������/g;
			$comment_split =~ s/(�I){15,}/�I�I�I�I�I�I�I�I�I�I�I�I�I�I�I/g;
			$comment_split =~ s/(�E){15,}/�E�E�E�E�E�E�E�E�E�E�E�E�E�E�E/g;
			$comment_split =~ s/(\Q�[\E){15,}/�[�[�[�[�[�[�[�[�[�[�[�[�[�[�[/g;
		}

		# �ߏ��w�����폜
		$comment_split =~ s/(��|w|v|��)((��|w|v|��){5,})/wwwww/g;

		# �t�q�k����{���`
		$comment_split =~ s/([a-z0-9]+),(jp|net|com)/$1.$2/g;
		$comment_split =~ s/(^|\/|[^h])ttp:\/\/([a-z0-9\.]+?)\//$1 http:\/\/$2\//g;
		$comment_split =~ s/mb2(\.|,)jp\/(-|\.)([0-9a-z]+?)\//mb2\.jp\/_$3\//g;
		$comment_split =~ s/(\.ntml|\.htm([^l<]|$))/\.html/g;
		$comment_split =~ s/\.html([^-#])/\.html $1/g;
		$comment_split =~ s/http:\/\// http:\/\//g;
		$comment_split =~ s/&quot;&gt;/ &quot;&gt;/g;
			if(!$main::secret_mode){ $comment_split =~ s/\/_sc([a-z0-9]{2,10})\//\/_test\//g; }

		# �g�єł��f�X�N�g�b�v�ł�
		#$comment_split =~ s/k([0-9]+)(|_data|_memo)\.html/$1$2\.html/g;
		#$comment_split =~ s/km0\.html//g;
		#$comment_split =~ s/mode=k(view|find)/mode=$1/g;
		#$comment_split =~ s/${auth_url}([a-z0-9]+)\/iview($|[^0-9a-zA-Z\-])/${auth_url}$1\/ $2/g;

		# ��������Adsense �̂t�q�k
		#$comment_split =~ s/https?:\/\/www\.google\.co\.jp\/(custom|cse)\?([a-zA-Z0-9%&;=_\-\.]+)&amp;q=([a-zA-Z0-9%_ \+\-]+)&amp;([a-zA-Z0-9%&;=\-]+)&amp;cx=%21([a-zA-Z0-9%&;=\-]+)(#[.]+)?/http:\/\/www\.google\.co\.jp\/search?hl=ja&amp;q=$3/g;
		if(!Mebius::alocal_judge()){	
			$comment_split =~ s/https?:\/\/www\.google\.co\.jp\/(custom|cse)\?([a-zA-Z0-9%&;=_\-\.]+)&amp;q=([a-zA-Z0-9%_ \+\-]+)&amp;([a-zA-Z0-9%&;=\-]+)(#[.]+)?/http:\/\/www\.google\.co\.jp\/search?q=$3&amp;sitesearch=mb2\.jp&amp;ie=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp/g;
		}

		# ���ꕶ����ϊ�
		$comment_split =~ s/&amp;([#a-zA-Z0-9]+);/��/g;

			# �폜�˗����̃��X�Ԃ𐮌` ( 1 )
			if($realmoto eq "delete"){
				$comment_split =~ s/#([A-Za-z])([a-zA-Z0-9\-_]+)//g;
				$comment_split =~ s/(NO\.|NO�D)/No./g;
			}

		# ���X�Ԃ̐��` ( 2 )
		# ��
		$comment_split =~ s/(No\.|No�D|�m���D|�m�n�D|&gt;&gt;|����|#)([0-9�O�P�Q�R�S�T�U�V�W�X]+)((,|\-|\~|\.|�A|�C|�B|�D|�E|�`|(\Q�|\E)|(\Q�[\E))([0-9,\.�O�P�Q�R�S�T�U�V�W�X�A�C�B�D�E\-�`(\Q�[\E)(\Q�|\E)]+)|;||$)/&fix_resnumber($1,$2,$3,$4)/eg;
		#$comment_split =~ s/No\.([0-9,\-]+)/&fix_redun_resnumber($1)/eg;
		$comment_split =~ s/No\.([0-9,\-]+)/ No\.$1 /g;

#>>445-565,6765


		# �s���̘A���󔒂��폜
		$comment_split =~ s/(�@)+$//g;
		$comment_split =~ s/\s$//g;

			# �����^�O�ϊ�
			#if($main::cgold >= 1 && ($comment_split =~ s/&apos;&apos;&apos;/$&/g) >= 2){
			#$comment_split =~ s|&apos;&apos;&apos;|<strong>|;
			#$comment_split =~ s|&apos;&apos;&apos;|</strong>|;
			#}

			## �������^�O�ϊ�
			#if($main::cgold >= 1 && ($comment_split =~ s/===/$&/g) >= 2){
			#$comment_split =~ s|===|<strike>|;
			#$comment_split =~ s|===|</strike>|;
			#}

		# �󔒂݂̂̍s�͍폜
		if($comment_split =~ /^([ �@]+)$/){ $comment_split = qq(); }

		# �q�b�g�J�E���^
		$hit++;

			# �Q���E���h�ȍ~�͉��s��ǉ�
			if($hit >= 2){ $return_check .= qq(<br>); }

		# ���^�[������ǉ�
		$return_check .= qq($comment_split);

	}


# �����S�̂ɑ΂��鏈��

	# ����/�����̉��s���폜
	if($main::kflag){
			if($main::bbs{'concept'} =~ /Sousaku-mode/){ $return_check =~ s/(<br>){5,}/<br><br><br><br><br>/g; }
			else{ $return_check =~ s/(<br>){3,}/<br><br><br>/g; }
	}

	# �A�����s���󔒂�����
	if($main::bbs{'concept'} =~ /Sousaku-mode/){
		$return_check =~ s/((<br>){20,})/<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>/g;
	}
	else{
		$return_check =~ s/(�@){20,}/<br>/g;	
			# �s���̉��s
			if($main::kflag){
				$return_check =~ s/^(<br>)+//g;
			}
			else{
				$return_check =~ s/^(<br>){2,}/<br><br>/g;
			}

		$return_check =~ s/((<br>){10,})/<br><br><br><br><br><br><br><br><br><br>/g;

		$return_check =~ s/((<br>)+)$//g;
	}



# ���^�[��
return($return_check);

}

#-----------------------------------------------------------
# ���X�Ԃ̐��`
#-----------------------------------------------------------
sub fix_resnumber{

# �Ǐ���
my($line,$plus,$return);
my($F1,$F2,$F3,$F4) = @_;

$return = "$F1$F2$F3";

# ����̏���
if($F4 eq ";"){ return(); }
if(!$in{'k'} && $device_type ne "mobile" && ($F1 eq "#") ){ return("$return"); }
#if($F1 eq "���X�ԁF"){ $plus = $F1; }

# �啶������������
($F2) = &bigsmall_number($F2);
($F3) = &bigsmall_number($F3);
$F3 =~ s/(�`|\~|(\Q�[\E)|(\Q�|\E))/\-/g;

# �J���}�ϊ�
$F3 =~ s/(\.|�A|�C|�B|�D|�E)/,/g;
$F4 =~ s/(\.|�A|�C|�B|�D|�E)/,/g;

# �p�����ȊO���������Ă���ꍇ
if($F2 ne "" && $F2 !~ /[0-9]/){ return($return); }
if($F3 ne "" && $F3 !~ /[0-9\-,]/){ return($return); }

# �O�͍ŏ��ɂ��Ȃ�
$F2 =~ s/^([0]+)([0-9]+?)/$2/g;
$F3 =~ s/([^0-9])([0]+)([0-9]+?)/$1$3/g;

# �s���`
$line = qq(${plus}No\.$F2$F3);

# �ŏI���`
$line =~ s/\-,/\-/g;
$line =~ s/,\-/,/g;
$line =~ s/\-{2,5}/\-/g;
$line =~ s/,{2,5}/,/g;
$line =~ s/\-$//g;
$line =~ s/\,$//g;

# �t���O
$fix_resnumber_flag = 1;

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# �Q�ȏ�͈͎̔w��𐮌`
#-----------------------------------------------------------
#sub fix_redun_resnumber{

# �Ǐ���
#my($line,$hit1,$hit2,$buf,$i);
#my($F1) = @_;

# ����
#($hit1) += ($F1 =~ s/\-/$&/g);
#($hit2) += ($F1 =~ s/\,/$&/g);

# ���^�[��
#if(!$hit1 || !$hit2){ return("No\.$F1"); }

# �W�J
#foreach(split(/\,/,$F1)){
#$i++;
#if($i >= 2){ $buf .= qq(\,); }
#$_ =~ s/^([0-9]+)\-([0-9]+)$/&fix_redun_resnumber2($1,$2)/e;
#$buf .= $_;
#}

# ���`�p�T�u���[�`��
#sub fix_redun_resnumber2{
#my($F1,$F2) = @_;
#my($i,$buf,$round);
#if($F1 > $F2){ ($F1,$F2) = ($F2,$F1); }
#$i = $F1;
#for($F1 .. $F2){
#$round++;
#if($i >= 100){ last; }
#if($round >= 2){ $buf .= qq(,); }
#$buf .= qq($i);
#$i++;
#}
#return($buf);
#}

# �s���`
#$line = qq(No\.$buf);

# ���^�[��
#return($line);
#}

#-----------------------------------------------------------
# �啶��������������������
#-----------------------------------------------------------
sub bigsmall_number{

my($check) = @_;

$check =~ s/�P/1/g;
$check =~ s/�Q/2/g;
$check =~ s/�R/3/g;
$check =~ s/�S/4/g;
$check =~ s/�T/5/g;
$check =~ s/�U/6/g;
$check =~ s/�V/7/g;
$check =~ s/�W/8/g;
$check =~ s/�X/9/g;
$check =~ s/�O/0/g;

return($check);

}

#-----------------------------------------------------------
# ���̑҂����Ԍv�Z ( ��� SNS �j
#-----------------------------------------------------------
sub wait_check{

my($check_length,$pcbonus) = @_;
my($waitmin,$toppa);


# �o�b�҂�����
@waitlist = (
'150=0.5',
'125=0.75',
'100=1.0',
'75=1.5',
'50=2.5',
'40=3.0',
'30=3.5',
'20=4.0',
'10=4.5',
'0=5.0'
);

# �g�ё҂�����
@kwaitlist = (
'150=0.5',
'125=0.75',
'100=1.0',
'75=1.25',
'50=1.5',
'40=1.75',
'30=2.25',
'20=2.75',
'10=3.25',
'0=5.0'
);



# �҂����Ԃ��v�Z�i�g�сj
if($k_access){
foreach(@kwaitlist){
my($length,$next) = split(/=/,$_);
# �҂����Ԍ���
if($check_length >= $length){ $waitmin = $next; $toppa = $length; last; }
}
}

# �҂����Ԃ��v�Z�i�o�b�j
else{
foreach(@waitlist){
my($length,$next,$bord) = split(/=/,$_);
# �҂����Ԍ���
if($check_length >= $length){ $waitmin = $next; $toppa = $length; last; }
}
# �ʃ{�[�i�X
if($pcbonus){ $waitmin *= $pcbonus; }
}


# �҂��b�����v�Z
$waitsec = int($waitmin*60);

# �X�y�V��������{�[�i�X
if($idcheck && $main::myaccount{'level2'} >= 1){ $waitsec -= 20; }

# ��������
if($waitsec < 30){ $waitsec = 30; }

# ���̑҂����Ԃ̕b�����v�Z
my $nextmin = int($waitmin);
my $nextsec = ($waitsec) - ($nextmin*60);


return($waitsec,$toppa,$nextmin,$nextsec);

}

use strict;

#-------------------------------------------------
#  �f�R���[�V�����̔��� - strict
#-------------------------------------------------
sub deco_check{

# �錾
my($type,$check,$category,$concept) = @_;
my($check2,$check_pure,$comment,$raretsu_flag,$ndeconum,$deconum,$error_flag);
my($error_decoper,$decoper,$adv_copynum,$comment_length,$datecopy_num,$datecopy_max,$copy_flag,$mechakucha_num,$mechakucha_max,$comment_split,$check_flag);
my($prev_text,$prev_sametext_flag,%dup_text,$over_length_flag);
our($concept,$short_length,$long_length,$decoper,$e_com,$guide_url,$category,$echeck_oneline,$alocal_mode);

# �t�b�N
$check2 = $check_pure = $comment = $check;

# ����̂��߂ɋ󔒉��s�A�t�q�k�����O
$check =~ s/(http\:\/\/[\w\.\,\~\!\-\/\?\&\+\=\:\@\%\;\#\%\*]+)//g;
($check) = Mebius::delete_all_space($check);

# �{���̕��������v�Z
$comment_length = int (length($check) / 2);

	# �����������̗���
	if($check =~ /^
		((��)+|(��)+|(��)+|(��)+|(��)+)
	$/x){
		$e_com .= qq(���Ђ炪�Ȃ𗅗񂵂Ȃ��ł��������B);
		$error_flag = qq(����������);
	}

	# �����������Ȃ��ꍇ�̓��^�[������
	if(!$error_flag && $comment_length <= 75) { return(0); } 

#$ndeconum += ($check =~ s/(�Q|��|��)/$&/g);
#$ndeconum += int( ($check =~ s/(\.)/$&/g) *0.5 );

# �P�s������̍ő啶�����i�S�p�j
my $maxlength_per_line = 1000;

	# �������ɉ����āA�ő�p�[�Z���g��ݒ� (���������������̕����������j
	$error_decoper = 50;
		if($comment_length >= 100){	$error_decoper = 50; }
		if($comment_length >= 200){	$error_decoper = 40; }
		if($comment_length >= 400){	$error_decoper = 35; }
		if($concept =~ /(Allow-decoration)/){ $error_decoper = 80; }
		elsif($type =~ /Sousaku/){ $error_decoper = 50; }

	# ���݂̃p�[�Z���g�擾
	($long_length,$short_length,$deconum) = &get_length("",$check);
	if($short_length){ $decoper = int($deconum / $short_length * 100); }

	# �f�R���[�V��������
	if($decoper > $error_decoper){
		$e_com .= qq(��<a href="${guide_url}%A5%C7%A5%B3%A5%EC%A1%BC%A5%B7%A5%E7%A5%F3">���͑S�̂ɑ΂��ċL���A�f�R���[�V�����A��؂���Ȃǂ��������܂��B�i ����${decoper}�� / �ő�${error_decoper}�� �j</a><br>�@�L���A�f�R���[�V�����A��؂���Ȃǂ����炵�Ă��������B<br>);
		$error_flag = qq(�f�R���[�V����);
	}




	# ������������֎~�i���`���N�`���ȕ��́j

		# �P�s���W�J
		foreach $comment_split (split(/<br>/,$check2)){

			# �Ǐ���
			my($buf1,$buf2,$max_buf1,$max_buf2);

			# �ݒ�
			$max_buf1 = 20;
			$max_buf2 = 50;

				# URL�����O
				($comment_split) = Mebius::url({ EraseURL => 1 },$comment_split);

				# ���O
				$comment_split =~ s/�i(.{1,10})�j//g;
				$comment_split =~ s/\((.{1,10})\)//g;

				# �P�s����������ꍇ
				if(length($comment_split) >= 2*$maxlength_per_line){
					$over_length_flag = int(length($comment_split)/2);
				}

				# �������̗�����֎~
				if($type !~ /Sousaku/){

						# �����肪���ȗ���`�F�b�N
						if($comment_split =~ /
							(��|��|��|��|��|��|��|��|��|��|�A|�C|�E|�G|�I|�@|�B|�D|�F|�H|�I|�H|�E|�`|\Q�[\E)
						{30,}
						/x){ $raretsu_flag = qq($&); }

						# ���Ђ炪��/�J�^�J�i����`�F�b�N
						if($comment_split =~ /
							([
							�����������������������������Ƃ����ĂƂȂɂʂ˂̂͂Ђӂւق܂݂ނ߂���������
							����������
							]){100,}/x)
						{ $raretsu_flag = qq($&); }
							#�A�C�E�G�I�J�L�N�P�R�T�V�X�Z�\�^�`�c�e�g�i�j�k�l�m�n�q�t�w�z�}�~������������������
							#�@�B�D�F�H
				}


				# �S�s�Ɠ������́H
				if(length($comment_split) >= 2*10 && $comment_split !~ /^(��|��)+$/){
					$dup_text{$comment_split}++;
				}
				if(length($comment_split) >= 2*5){
						if($prev_text eq $comment_split){ $prev_sametext_flag++; }
					$prev_text = $comment_split;
				}

				# ���ʂ̓��{��̓G�X�P�[�v
				if(($comment_split =~ s/(�A|�B|�u|�v)/$&/g) >= 5){ $max_buf1 *= 3; } 

			# ��i�ڃ`�F�b�N
			$buf1 += ($comment_split =~ s/(��|��[^��]|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��)/$&/xg);
				if(($comment_split =~ s/(��|��|��|��|��)/$&/g) >= 5){ $buf1 = 0; }


			# ��i�ڃ`�F�b�N
			$buf2 += ($comment_split =~ s/(�P|�Q|�R|�S|�T|�U|�V|�W|�X|�O|��|�z|�G)/$&/xg);

				# �O�i�ڃ`�F�b�N
				if($comment_split =~ /([a-zA-Z0-9]{50,})/){ $mechakucha_num = "?"; $mechakucha_max = 50; last; }

				# �Е�����萔�ȏ゠��ꍇ�́A�P�ɂQ�����Z����
				if($buf1 >= 10 || $buf2 >= 25){ $buf1 += $buf2; }

				# ���ߔ���
				if($buf1 >= $max_buf1){ $mechakucha_num = $buf1; $mechakucha_max = $max_buf1; $check_flag = $comment_split; last; }
				if($buf2 >= $max_buf2){ $mechakucha_num = $buf2; $mechakucha_max = $max_buf2; $check_flag = $comment_split; last; }


				
		}

			# �e�Ƃ̕��͂�W�J
			my $max_duplication_line = 5;
			my($dupulication_line);
			foreach(keys %dup_text){
				if($dup_text{$_} >= $max_duplication_line){
					if($dupulication_line){ $dupulication_line .= qq(�@�Y���s�F$_�@( $dup_text{$_} �s / $max_duplication_line �s ) <br$main::xclose>); }
					else{ $dupulication_line = qq(�@�Y���s�F$_�@( $dup_text{$_} �s / $max_duplication_line �s ) <br$main::xclose>); }
				}
			}
			if($dupulication_line && !$error_flag && $type !~ /Sousaku/){
				#$e_com .= qq(���܂����������s���A�������������ނ��Ƃ͏o���܂���B<br>$dupulication_line);
				#$error_flag = qq(�������͍s-typeB);
			}


			# �������̗��񔻒�
			if($raretsu_flag){
				$e_com .= qq(��<a href="${guide_url}%CA%B8%BB%FA%BF%F4%B2%D4%A4%AE">�L���╶���̘A�����������܂��B</a> ( $raretsu_flag )<br>�@�u�[�[�[�[�v�u�`�`�`�`�v�u�I�I�I�I�v�u�E�E�E�E�v�u�����������v�ȂǘA�������炵�Ă��������B<br>);
				$error_flag = qq(�������� - $raretsu_flag);
			}

			# �d���s�̔���
			my $max_dupulicate_line_num = 5;
			if($prev_sametext_flag >= $max_dupulicate_line_num && !$error_flag && $type !~ /Sousaku/){
				$e_com .= qq(�����͑S�̂œ����s���������܂��B ( $prev_sametext_flag�s / ${max_dupulicate_line_num}�s )<br>);
				$error_flag = qq(�������͍s-typeA);
			}

			# �Œ��ꒃ�ȕ���
			if($mechakucha_num && !$error_flag && $type !~ /Sousaku/){
				$e_com .= qq(��������Œ��ꒃ�ɑł��Ȃ��ł��������B�r�炵�͍폜/���e�����������Ă��������ꍇ������܂��B ( $mechakucha_num / $mechakucha_max )<br>�@�Y���s�F <em>$check_flag</em><br>);
				$error_flag = qq(�Œ��ꒃ($mechakucha_num/$mechakucha_max)-$check_flag);
			}


			# ��������P�s
			if($over_length_flag && !$error_flag && $type !~ /Sousaku/){
				$e_com .= qq(���P�s���������܂��B�K�x�ɒi���������Ă��������B( $over_length_flag ���� / $maxlength_per_line ���� )<br>);
				$error_flag = qq(��������P�s($mechakucha_num/$mechakucha_max)-$check_flag);
			}

	# ���r�A�h�̑�ʃR�s�[�֎~
	if(index($check_pure,"�_���[�W") >= 0 && !$error_flag){
		$adv_copynum = ($check_pure =~ s|HP ([0-9,(��)(��)(��)]+) / ([0-9,(��)(��)(��)]+)|$&|g);
		if($adv_copynum >= 4){
			$e_com .= qq(�����r�A�h�퓬���ʂ̑�ʃR�s�[��A�]�ڂ̂ݓ��e�͂��������������B�K�v�ȕ����݂̂𔲐����A�R�����g�⊴�z�������Ă��������B( $adv_copynum\pt / 5pt )<br>);
			$error_flag = qq(���r�A�h);

		}
	}


# �f������̃R�s�[���֎~
$datecopy_num += ($check2 =~ s|([0-9]{4})/([0-9]{2})/([0-9]{2}) ([0-9]{2}):([0-9]{2})|$&|g);
$datecopy_num += ($check2 =~ s/(\d{1,4})(\s|�F)(.+?)�F(\d{4})\/(\d{2})\/(\d{2})\((��|��|��|��|��|�y|��)\)\s(\d{2}):(\d{2}):(\d{2})(:\d{2})?/$&/g);
$datecopy_num += ($check2 =~ s/--------------------------------------------------------/$&/g);

#if($check2 =~ /--------------------------------------------------------/){ $datecopy_max = 1; }
$datecopy_max = 5;
if($datecopy_num >= $datecopy_max){ $copy_flag = 1; }
#if(($check2 =~ s/--------------------------------------------------------/$&/g) >= 3){ $copy_flag = 1; $datecopy_num = 1; }

	if($copy_flag && !$error_flag){
		$e_com .= qq(���f��������̊ۂ��ƃR�s�[�A��ʃR�s�[�͂��������������B( $datecopy_num \pt / $datecopy_max pt )<br>);
		$error_flag = qq(�R�s�[);
	}

	# Echeck���L�^
	if($error_flag){
		Mebius::Echeck::Record("","Kasegi","$comment");
		Mebius::Echeck::Record("","All-error","$comment");
	}

# Echeck�L�^�p
if($check_flag){ $echeck_oneline = $check_flag; }

# ���^�[��
return($error_flag,$deconum,$decoper,$error_decoper);

}

#-------------------------------------------------
#  �X�y�[�X���� - strict
#-------------------------------------------------
sub space_check{

my($type,$check,$category,$concept) = @_;
my($none,$comment) = @_;
my($aaflag1,$aaflag_last,$aanum,$spacenum,$allspacenum,$halfnum,$error_flag);
my($spaceper,$error_spaceper,$space_com_leng,$spaceover_num,$spaceover_num2,$max_spaceover,$check_flag,$br_num,$all_text_length);
my($basic_init) = Mebius::basic_init();
our($e_com);

	# �����������Ȃ��ꍇ�̓��^�[��
	if(length($check) < 30*2){ return; }

	# �`�`����i���i�j
	#if($check =~ /(�P|��)/){ $aaflag1 = 1; }
	if($check =~ /(�L|�E|�)(��|�D|��|_�T|�t)(�M|�E|�|`|T)/ && $check =~ /(��|��|�t|�Q�Q)/){ $aaflag_last = 1; }
	if($check =~ /(��([ �@]{3,})��|(�R�s�y|\Q�R�s�[\E)�����)/){ $aaflag_last = 1; }
	if($check =~ /(AA|�`�`|\Q�A�X�L�[\E)/){ $aaflag_last = 1; }

	# �`�`����i���i�j
	#if($aaflag1){
	#	$aanum += ($check =~ s/(�R�s�y)/$&/g);
		#if(($check =~ s/(::|;;|\Q|\E|\Ql\E|\Q�b\E|\Q��\E)/$&/g) >= 20){ $aaflag_last = 1; }
	#	if($aanum >= 5){ $aaflag_last = 1; }
	#	if($check =~ /��(�Q)?��/){ $aaflag_last = 1; }
	#}

	# ���{�����P�s���`�F�b�N���Ă`�`����
	foreach my $comment_split (split(/<br>/,$check)){

		# �Ǐ���
		my($text_length,$space_length);
		$text_length = length($comment_split) / 2;

			# ���̍s�ɃX�y�[�X������ꍇ�����A�`�F�b�N�i�L���݂̂̍s���`�F�b�N���Ȃ��j
			if(($comment_split =~ s/(�@|�Q�Q|��|��|�t|\s)/$&/g) >= 2){

				# AA�����𔻒�
				$space_length += ($comment_split =~ s/(�@|��|��|�c|�l|�x|��|��|��|��|��|��|�Q|�P|�^|�j|�i|\Q��\E|\Q�b\E|\Q||\E|ii|::|;;|,,)/$&/g);
				$space_length += int(($comment_split =~ s/(\s|\Q|\E)/$&/g)) / 2;
				# ���� �c�y\Ql\E�z �͕����R�[�h�̖��Ō딻�肪�N���邽�ߎg��Ȃ�

				# �P�s�ɐ�߂�h�`�`�����h�̊������v�Z�A�������ȏ�ł���΂`�`����l�𑝂₷
				if($text_length && $space_length){
					if($text_length >= 5 && ($space_length / $text_length) * 100 >= 70){
						$spaceover_num++;
						$check_flag = join (" / " , $check_flag , $comment_split , "$space_length / $text_length");
					}
				}
			}
	}


	# �󔒍s�̃`�F�b�N
	if($aaflag_last){ $max_spaceover = 3; } else { $max_spaceover = 6; }
	if($spaceover_num >= $max_spaceover){
			$e_com .= qq(���󔒍s�A�L���s���������܂��B�`�`��}���폜���Ă��������B$spaceover_num / $max_spaceover<br>);
			$e_com .= qq(�@�Y���s�F$check_flag<br>);
			Mebius::Echeck::Record("","Kasegi","$comment");
			Mebius::Echeck::Record("","All-error","$comment");
		$error_flag .= qq(�󔒍s����($spaceover_num/$max_spaceover));
	}

	# �ő�p�[�Z���g�̐ݒ�
	if($aaflag_last){ $error_spaceper = 15; } else { $error_spaceper = 80; }
	$error_spaceper = int($error_spaceper) + 1;

# ���݃p�[�Z���g�̎擾
$allspacenum += ($check =~ s/(�@|�P)/$&/g);
$allspacenum += ($check =~ s/ /$&/g) / 2;
if(length($check)*2) { $spaceper = int(($allspacenum / (length($check)*2)) * 100); }

	# �X�y�[�X�l��100%�ȏ�̏ꍇ�A�\���l�C��
	if($spaceper > 100){ $spaceper = 100; }

	# ���X�y�[�X����
	if($spaceper > $error_spaceper) {
			if($aaflag_last){ $e_com .= qq(��AA\(�A�X�L�[�A�[�g\)�͋֎~�ł��B<br>); }
		$e_com .= qq(��<a href="$basic_init->{'guide_url'}%A5%B9%A5%DA%A1%BC%A5%B9%C0%A9%B8%C2">���͗ʂɑ΂��āA�X�y�[�X�i�󔒕����j���������܂��B	�i ����${spaceper}�� / �ő�${error_spaceper}�� �j</a><br>
		�@�u�S�p�X�y�[�X�v�u���p�X�y�[�X�v�̗ʂ����炵�Ă��������B<br>
		�@���{��Ƃ��āA�X�y�[�X�Ȃ��ł������镶�͂𐄏����܂��B<br>);
		$error_flag = qq(�p�[�Z���e�[�W����);
		Mebius::Echeck::Record("","Kasegi","$comment");
		Mebius::Echeck::Record("","All-error","$comment");
	}

	# ���n�[�t�L�^
	elsif($spaceper > $error_spaceper / 2){
		#Mebius::Echeck::Record("","SPACE-HIDDEN","$comment");
	}



	# �����s�����̔���
	my $per_br_num = 2; # �S�p������������A�P�̉��s��������
	my $max_br_num = int($all_text_length / $per_br_num);

	# ���{����W�J
	foreach my $comment_split (split(/<br>/,$check,-1)){
		$br_num++;
		$comment_split =~ s/( |�@)//g;
		$all_text_length += length($comment_split) / 2;
	}

	# �����s����萔�ȏ゠�鎞�ɂ�������
	if($br_num >= 5){
		my $max_br_num = int($all_text_length / 1);
			if($br_num > $max_br_num){
				$e_com .= qq(���e�L�X�g�ʂɑ΂��āA���s���������܂��B( ����${br_num}�� / �ő�${max_br_num}�� )<br>);
			}
	}


	# �`�F�b�N���ʂƂ���AA�����Ԃ�
	if($aaflag_last && $error_flag){ $error_flag .= qq( - AA����); }

# ���^�[��
return($error_flag,$spaceper,$error_spaceper);

}



no strict;


#-----------------------------------------------------------
# ���[���A�h���X�̃`�F�b�N
#-----------------------------------------------------------
sub address_check{

# �錾
my($mailto) = @_;
$mailto =~ s/( |�@)//g;

if($mailto eq "") { &error("���[���A�h���X����͂��Ă��������B"); }
if(length($mailto) > 256) { &error("���[���A�h���X���������܂��B"); }
if($mailto =~ /[^0-9a-zA-Z_\-\.\@]/) { &error("���[���A�h���X�̏������Ԉ���Ă��܂��B"); }
if($mailto && $mailto !~ /^[\w\.\-]+\@[\w\.\-]+\.[a-zA-Z]{2,6}$/) { &error("���[���A�h���X�̏������Ԉ���Ă��܂��B"); }

$mailto;

}

#-----------------------------------------------------------
# �S�Ẵ`�F�b�N
#-----------------------------------------------------------
sub all_check{

my($type,$check,$name) = @_;

$type .= qq( Sjis-to-utf8);

# �I�[�o�[�t���[�`�F�b�N
Mebius::Regist::OverFlowCheck(undef,$check);

($check) = base_change($check);
Mebius::Regist::private_check($type,$check);
(undef,$deconum) = Mebius::Regist::ChainCheck($type,$check);
url_check($type,$check);
Mebius::Regist::sex_check($type,$check);
Mebius::Regist::EvilCheck($type,$check);
deco_check($type,$check);
space_check($type,$check);
our($bglength,$smlength) = get_length($type,$check,$deconum);

if($name){ ($name) = shift_jis(Mebius::Regist::name_check($name)); }

$e_error = $e_access . $e_sub . $e_com;

	if($type =~ /Error-view/){
		main::error_view();
	}

return($check,$name);

}


#-----------------------------------------------------------
# ���ӓ��e���L�^
#-----------------------------------------------------------
sub rcevil{

# �Ǐ���
my($typename,$comment,$handle,$url,$sub) = @_;
my($line,$i,$flag,@keywords,$keyword);
our($echeck_oneline,$secret_mode,$category,%in);

# ���^�[��
if($secret_mode || $main::bbs{'concept'} =~ /Sousaku-mode/|| $category eq "narikiri" || $category eq "mebi"){ return; }

# �Ď��L�[���[�h
@keywords = ('���A�h','�d�b','�莆','����','�Z��','��','���[��','�����[�ҁ[','�W�F�[�s�[','����','tel','�h�b�g','�ǂ���','�E�U��','������','�Z�b�N�X'
		,'�{��');

	# �L�[���[�h������
	foreach $keyword (@keywords){
		if(index($comment,$keyword ) >= 0){ $flag = 1; }
	}

# �A���[�g��˔j�����ꍇ�͖������ɋL�^
if($in{'break_alert'}){ $flag = 1; }

if(!$flag){ return; }

$line .= qq(1<>$typename<>$title<>$url<>$sub<>$handle<>$comment<>$i_resnumber<>$time<>$date<>$category<><>$echeck_oneline<>\n);

# �t�@�C�����J��
open(IN,"<${int_dir}_sinnchaku/rcevil.log");
	while(<IN>){
		$i++;
		if($i < 500){ $line .= $_; }
	}
close(IN);

# �t�@�C���������o��
Mebius::Fileout("","${int_dir}_sinnchaku/rcevil.log",$line);

}

#-----------------------------------------------------------
# ���݂��Ȃ����X�ԕ\�L�����������N���Ȃ��悤��
#-----------------------------------------------------------
#sub checkres_number{

#my($check,$res) = @_;

#$check =~ s/No\.([0-9,\-]+)/&do_checkres_number($1,$res)/eg;

#return($check);

#sub do_checkres_number{

#my($check,$res) = @_;
#my($flag);
#my($res_start,$res_end) = ($check,$check);

#if($check =~ /-/){ ($res_start,$res_end) = split(/-/,$check); }

#if($check =~ /,/){
#foreach(split(/,/,$check)){
#if($_ > $res_end){ $res_end = $_; }
#if($_ < $res_start){ $res_start = $_; }
#if($_ eq ""){ $flag = 1; }
#}
#}

#if($res_end > $res || $flag){ return("&gt;&gt;$check") }
#else{ return("No.$check"); }
#}

#}


#-----------------------------------------------------------
# ���e��������d�����e���֎~
#-----------------------------------------------------------
sub regist_double_check{

# �錾
my($type,$comment) = @_;
my($flag,$thread_link);
my($init_directory) = Mebius::BaseInitDirectory();
my $debug = new Mebius::Debug;
require "${init_directory}part_newlist.pl";
our($e_com);

	# ���
	if($debug->escape_error()){ return(); }
	if($comment eq ""){ return; }

# �T�C�g�S�̂̍ŐV���X����A�d���`�F�b�N
($flag,$thread_link) = Mebius::Newlist::threadres("RES Buffer Duplication-check",$comment);
	if(!$flag){ ($flag,$thread_link) = Mebius::Newlist::threadres("THREAD Duplication-check",$comment); }

	if($flag) {
		$e_com .= qq(����d���e�ł͂���܂��񂩁H�@ ���̋L�� ( $thread_link ) ���m�F���Ă݂Ă��������B[B]<br>);
		if($main::myadmin_flag >= 5){ $e_com .= qq(�`�F�b�N�F $flag<br>); }
		$doublechecked_flag = 1;
	}

return($flag);

}

#-----------------------------------------------------------
# �o�b�h�L�[���[�h���`�F�b�N
#-----------------------------------------------------------
sub badword_check{

# �Ǐ���
my($check) = @_;
my($flag);

# �L�[���[�h����
#if($check =~ /(���q|�܂�|�}���R|�}���R|�}�Z�R|����|�N�`��|�S��|�����ς�|�I�b�p�C|����|����|�E���R|�I�i�j)/){ $flag = 1; }
#if($check =~ /(�~�[|�~��|�~�Q|DQN|�c�p�m)/){ }
#if($check =~ /(�N�\|�J�X)/){ }
#if($check =~ /(�c��)/){ }

# �G���[
if($flag){
$e_com .= qq(�����̃L�[���[�h�͓o�^�ł��܂���B<br>);
}

}

use strict;

#-----------------------------------------------------------
# �G���[��ʂ�\������
#-----------------------------------------------------------
sub error_view{

# �錾
my($type,$rootin) = @_;
my(undef,undef,$action) = @_ if($type =~ /View-break-button/);

my($error,$break_alert_checked,$edit_alert_checked,$submit_button);
our($a_com,$e_access,$e_sub,$e_com,%in,$break_alert_input,$guide_url);

# �G���[���܂Ƃ߂�
$e_com = $e_access . $e_sub . $e_com;

	# �A���[�g���G���[�ɕς���ꍇ
	if(($type =~ /AERROR/ && $a_com && (!$in{'break_alert'} || $in{'preview'})) || $e_com){

		# ����
		my $keep_e_com = $e_com;
		$e_com .= $a_com;

			# �`�F�b�N��`
			if($in{'break_alert'}){ $break_alert_checked = $main::parts{'checked'}; }
			else{ $edit_alert_checked = $main::parts{'checked'}; }

			# �A���[�g�������āA�G���[���Ȃ��ꍇ
			if($a_com && !$keep_e_com){

					# ���M�{�^�����\������ꍇ
					if($type =~ /View-break-button/){
						$e_com .= qq(<form method="post" action="./"><div>);
					}

				$e_com .= qq(�@�@<input type="radio" name="break_alert" value="0" id="edit_alert"$edit_alert_checked$main::xclose>);
				$e_com .= qq(<label for="edit_alert"> ���e��ύX���܂�</label> );
				$e_com .= qq(<input type="radio" name="break_alert" value="1" id="break_alert"$break_alert_checked$main::xclose>);
				$e_com .= qq(<label for="break_alert"> ���Ȃ��̂ł��̂܂ܑ��M���܂� ( <a href="$guide_url">���[��</a> ��������肢���܂� )</label> <br$main::xclose>);
					
					# ���M�{�^�����\������ꍇ
					if($type =~ /View-break-button/){

							# �S�Ă� POST ���e��W�J
							foreach(split(/&/,$main::postbuf)){

								# �L�[�ƒl�𕪉�
								my($key,$value) = split(/=/,$_);

								# �G���R�[�h
								my($value_decoded) = Mebius::Decode(undef,$value);

									# �L�[�ɂ���Ă̓G�X�P�[�v
									if($key eq "break_alert"){ next; }

									# �R�����g�ύX
									if($key eq "comment"){
										my $textarea = $value;
										$textarea =~ s/<br>/\n/g;
										$submit_button .= qq(<br$main::xclose><textarea name="comment" style="width:50%;">$value_decoded</textarea><br$main::xclose>);
									}

									# Hiiden �l�őg�ݍ��ޏꍇ
									else{
										$submit_button .= qq(<input type="hidden" name="$key" value="$value_decoded"$main::xclose>);
									}
							}

						$submit_button .= qq(<input type="submit" value="���M����"$main::xclose>);
						$submit_button .= qq(</form></div>);
					}

			}
	}

	# �����N�̃^�[�Q�b�g��ύX
	if($e_com && $type =~ /Target/ && !$main::kflag){
		$e_com =~ s|<a href="(.+?)">|<a href="$1" target="_blank" class="blank">|g;
	}


no strict;

	# �G���[������ꍇ�A�e�G���[���[�h�Ɉڍs
	if($e_com || $in{'preview'}){
		if($rootin && $type =~ /Not-tell/){ &$rootin(); } 
		elsif($rootin){ &$rootin("$e_com"); } 
		else{ &error("$e_com$submit_button"); }
	}

}



1;

