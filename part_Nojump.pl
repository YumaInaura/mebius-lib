
package main;

#-----------------------------------------------------------
# �C�ӂ̃��X�ԂɃW�����v - strict
#-----------------------------------------------------------
sub bbs_number_jump{

# �Ǐ���
my($number,$number2,$i,$no,$move);
our(%in);

# �L���ԏ��� 
$no = $in{'no'};
if($no eq ""){ &error("�L���Ԃ��w�肵�Ă��������B"); }

# ���X�ԏ���
$number = $in{'No'};

# �S�p�����𔼊p�����ɒu����
$number =~ s/�P/1/g;
$number =~ s/�Q/2/g;
$number =~ s/�R/3/g;
$number =~ s/�S/4/g;
$number =~ s/�T/5/g;
$number =~ s/�U/6/g;
$number =~ s/�V/7/g;
$number =~ s/�W/8/g;
$number =~ s/�X/9/g;
$number =~ s/�O/0/g;

$number =~ s/\Q�[\E/-/g;
$number =~ s/\Q�|\E/-/g;
$number =~ s/\Q�O\E/-/g;
$number =~ s/\Q^\E/-/g;

$number =~ s/no\./,/ig;

$number =~ s/( |\/|\.|\:|\;|\\)/,/g;
$number =~ s/(�@|��|�C|�A|�B|�C|�D|�E|�F|�G)/,/g;

# ���֌W�ȕ����������
$number =~ s/([^0-9,\-])//g;

# �V���[�v�ԍ�����
#($move) = split(/,/,$number);
#($move) = split(/-/,$move);

# ���X�Ԃ��Ȃ��ꍇ
if($number eq ""){ &error("���X�Ԃ��w�肵�Ă��������B"); }
unless($number =~ /\w/){ &error("���X�Ԃ��w�肵�Ă��������B"); }

	# �W�J���āA�ςȕ\�L���C��
	foreach(split(/,/,$number)){
		if($_ ne ""){
				if($i){ $number2 .= ","; }
			$number2 .= $_;
			$i++;
		} 
	}

# ���_�C���N�g
Mebius::Redirect("","$no.html-$number2#a");

}


1;

