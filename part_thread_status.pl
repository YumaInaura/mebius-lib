
use strict;
package main;

#-----------------------------------------------------------
# �폜�ς݃y�[�W
#-----------------------------------------------------------
sub thread_get_deletelock{

# �錾
my($type,$main_thread,$use_thread) = @_;
my($delman,$delday,$deltime,$reason) = split(/=/,$main_thread->{'delete_data'});
my($flag,$deleted_text);
our($css_text,$repairform,$khrtag,$status_flag,$now_url,$guide_url);
our($title,$server_domain,$sub_title,$int_dir,$xclose,$k_access,%category,$moto);

# �J�e�S���ݒ���擾
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

	# CSS��`(�\��폜)
	if($type =~ /LIGHT/){
		$css_text .= qq(
		div.lightdeleted{border:solid 1px #000;padding:1em;line-height:1.6em;}
		.reason{font-size:140%;}
		);
	}

	# CSS��`(���S�폜)
	if($type =~ /HEAVY/){
		$css_text .= qq(
		a.white{color:#00f;}
		div.deleted{border:solid 1px #000;padding:1.5em 2.0em;}
		ul{margin:1em 0em;font-size:130%;}
		li{color:#f00;}
		);
	}

# �폜���R��荞��
require "${int_dir}part_delreason.pl";
my($delreason_text,$delreason_subject) = &delreason($reason);

	# �폜���R
	if($delreason_text){ $delreason_text = qq(���폜���R�F $delreason_text<br$xclose>); }

	# �^�C�g����`
	if($type =~ /MOBILE/){ &thread_set_title_mobile(); }
	else{ &thread_set_title($main_thread); }

	# �����N�؂�̏ꍇ�A�C��
	if($type =~ /(LIGHT|HEAVY)/ && $ENV{'REQUEST_METHOD'} eq "GET"){
		if($type =~ /MOBILE/){ &repairform(); }
		else{ &repairform(); }
	}

	# �X�e�[�^�X�R�[�h
	if($type =~ /(LIGHT|HEAVY)/){
			if(!$status_flag && !$k_access){
				print qq(Status: 410 Gone\n);
				$status_flag = 1;
			}
	}

	# �y�[�W�^�C�g����ύX
	if($type =~ /HEAVY/){ $sub_title = "�폜�ς݋L��"; }

	# �\��폜�̏ꍇ
	if($type =~ /LIGHT/){
			my($how_delete_reserve) = shift_jis(Mebius::second_to_howlong({ TopUnit => 1 } , $main_thread->{'delete_reserve_time'} - time));
		if($delreason_text){ $delreason_text = qq(<strong class="reason">$delreason_text</strong><br$xclose>); }
		$deleted_text .= qq(
		<div class="lightdeleted">
		<span class="red">���̋L���́A$title�̃��j���[����폜�ς݂ł��B<br$xclose>
		���� $how_delete_reserve �ŋL���{�̂����S�ɍ폜����܂��B<br$xclose><br$xclose>
		$delreason_text
		���폜�ҁF $delman / �����s�����F $delday<br$xclose><br$xclose>
		<a href="$init_bbs->{'report_thread_href'}">���폜�˗����`�F�b�N</a> / 
		<a href="${guide_url}%BA%EF%BD%FC%A3%D1%A1%F5%A3%C1">���폜�p���`</a></span>
		</div>
		<br$xclose>
		);
		return($deleted_text);
	}

	# ���S�폜�̏ꍇ
	if($type =~ /HEAVY/){

		my $print = qq(
		<div class="deleted">
		<h1><a href="${guide_url}410">410 Gone</a> - �폜�ς� -</h1>
		<strong style="font-size:140%;">$delreason_text</strong><br$xclose>
		���폜�ҁF $delman �����s�����F $delday<br$xclose>
		<br$xclose>
		���̂悤�ȃ��[���ᔽ���Ȃ��������ǂ����A���m���߂��������B
		<ul>
		<li>�l���̌f�ځB</li>
		<li>�}�i�[�ᔽ�B</li>
		<li>�d���L�� / �J�e�S���Ⴂ�B</li>
		<li>�l�I�ȋL��/�Q���҂̌���B</li>
		<li>�����n�A�o��n���p�B</li>
		<li>�������҂��A��`�Ȃǂ̖��f�s�ׁB</li>
		<li>�L���̃e�[�}���B���B�e�[�}����ȏ゠��B</li>
		<li>�K�v�Ȓ��ӏ����A�`�F�b�N�̕s���B</li>
		<li>���[�J�����[���ᔽ�B</li>
		</ul>
		�ڂ�����<a href="${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6">�V�K���e�̃��[��</a>�E<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">���r�E�X�����O�֑�</a>���������������B<a href="${guide_url}%BA%EF%BD%FC%A3%D1%A1%F5%A3%C1">�폜�p���`</a>������܂��B
		</div>
		);

		Mebius::Template::gzip_and_print_all({ ReadThread => 1 , read_thread_res_number => $use_thread->{'res'} },$print);

		exit;
	}



}


#-----------------------------------------------------------
# ���b�N���̋L��
#-----------------------------------------------------------
sub thread_status_lock{

# �錾
my($type,$delete_data,$lock_end_time) = @_;
my($delman,$delday,$deltime,$reason) = split(/=/,$delete_data);
my($lockview_line);

	# �������Ԃ��߂��Ă���ꍇ
	if($lock_end_time && $main::time >= $lock_end_time){ return(); }

# �폜���R��荞��
require "${main::int_dir}part_delreason.pl";
my($delreason_text,$delreason_subject) = &delreason($reason);

# �\�����e (��)
$lockview_line .= qq(<div class="thread_status">);
$lockview_line .= qq(<a href="$main::guide_url" class="white">���̋L���̓��b�N���ł�);
	if($delreason_text){ $lockview_line .= qq( ( $delreason_subject ) ); }
$lockview_line .= qq(</a>);

	# ��������
	if(time < $lock_end_time){
		my($how_lock) = Mebius::SplitTime("Get-top-unit Omit-top-time",$lock_end_time - $main::time); 
		$lockview_line .= qq( - ����$how_lock�ŉ�������܂��B);
	}

$lockview_line .= qq(</div>\n);
$main::css_text .= qq(div.lock_tell{background:#fff;font-weight:normal;});

return($lockview_line);


}


1;
