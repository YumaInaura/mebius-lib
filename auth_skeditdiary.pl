
use strict;
use Mebius::Penalty;
package main;

#-----------------------------------------------------------
# SNS ���L�̃��X����
#-----------------------------------------------------------
sub auth_skeditdiary{

# �錾
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
our($backurl);

	# ���M�^�C�v�`�F�b�N
	if(!Mebius::Query::post_method_judge() && !Mebius::alocal_judge()){ main::error("GET���M�͏o���܂���B"); }

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$my_account->{'login_flag'}){ &error("���L���폜����ɂ́A���O�C�����Ă��������B"); }

# �Y���s���Ȃ��ꍇ
#if(!$flag){ &error("���s�ł��܂���ł����B���ɑ���ς݂��A�K�؂ȃ`�F�b�N�������Ă��܂���B"); }
my($controled) = Mebius::SNS::Diary::query_to_control();

	# ���_�C���N�g
	if(!Mebius::redirect_to_back_url()){
		Mebius::redirect("$basic_init->{'auth_url'}$controled->{'controled_account'}->[-1]");
	}

	#if($controled->{'thread_delete_flag'}){
	#	Mebius::redirect("$basic_init->{'auth_url'}$controled->{'controled_account'}->[-1]/#DIARY");
	#} else {
	#	Mebius::redirect("$basic_init->{'auth_url'}$controled->{'controled_account'}->[-1]/d-$controled->{'controled_thread'}->[0]#S$controled->{'control_reses'}->[0]");
	#}

# �I��
exit;

}

1;
