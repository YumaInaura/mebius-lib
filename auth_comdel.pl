
package main;
use strict;
use Mebius::SNS::CommentBoad;


#-----------------------------------------------------------
# �`���ł̃R�����g�폜
#-----------------------------------------------------------
sub auth_comdel{

# �Ǐ���
my($file,$line,$past,$pastline,$deleted_flag);
my($delete_url,@years,%account,$jump_url,$select_year,$yearfile);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
our($postflag,$backurl_jak_flag,$backurl);

	# ���M�^�C�v�`�F�b�N
	if(!$postflag && !Mebius::alocal_judge()){ main::error("GET���M�͏o���܂���B"); }

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$my_account->{'login_flag'}){ main::error("�R�����g���폜����ɂ́A���O�C�����Ă��������B"); }

# �����`�F�b�N
my $account = $param->{'account'};
$account =~ s/[^0-9a-z]//g;
	if(Mebius::Auth::AccountName(undef,$account)){ main::error("�A�J�E���g���̎w�肪�ςł��B"); }

#	if($file eq ""){ &error("�ΏۃA�J�E���g���w�肵�Ă��������B�B"); }

# �N�x�̒�`
$select_year = $param->{'year'};
$select_year =~ s/\D//g;

Mebius::SNS::CommentBoad::query_to_control();

# �v���t�B�[�����J��
#Mebius::Auth::File("",$file);

# ���b�N�J�n
#&lock("auth$file");

# ���s���O���X�V
#($deleted_flag,@years) = file_authcomdel("Nowfile",$file);

	# �����s���O����N�x�w������o���Ȃ������ꍇ�́A��������N�x���`
	#if(@years <= 0 && $select_year){
	#	push(@years,$select_year);
	#}
	#if(@years <= 0){ main::error("���s�ł��܂���ł����B�폜�ł�����e���Ȃ����A�Ώۂ̔N�x���w�肳��Ă��܂���B"); }

	# ���u���s�R�����g�폜�v�ŋL�������N�x�����ׂēW�J
	#foreach $yearfile (@years){

		# �N���̉ߋ����O���X�V
	#	if(file_authcomdel("Pastfile",$file,$yearfile)){ $deleted_flag = 1; }
	#}

	# �폜�������g���Ȃ��ꍇ
	#if(!$deleted_flag){ &error("���s�ł��܂���ł����B����ł���R�����g�����݂��Ȃ����A���ɑ���ς݂ł��B"); }

# ���b�N����
#&unlock("auth$file");


	# ���_�C���N�g�i�Ǘ����[�h�֖߂�j
	if($backurl_jak_flag && $my_account->{'admin_flag'}){
		Mebius::Redirect("","$backurl&jump=newres");
	}
	# ���_�C���N�g�i�`���֖߂�j
	else{
		Mebius::Redirect("","$basic_init->{'auth_url'}${account}/$param->{'thismode'}#COMMENT");
	}

# �I��
exit;

}



1;
