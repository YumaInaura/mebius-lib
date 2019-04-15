
use strict;
use Mebius::Handle;
package Mebius::BBS;

#-----------------------------------------------------------
# �M�������L���O�̃C���f�b�N�X
#-----------------------------------------------------------
sub HandleRankingIndex{

# �錾
my($page_title,$plustype_ranking,$history_line,$file_type);
my($year,$monthf) = ($main::submode2,$main::submode3);

	
	# �e��G���[
	if($main::bbs{'concept'} =~ /Not-handle-ranking/){
		main::error("���̌f���ł̓����L���O���J�Â��Ă��܂���B");
	}

# CSS��`
$main::css_text .= qq(
h1{font-size:150%;}
h2{font-size:130%;}
);

	# �g�єłւ̑Ή�
	if($main::device_type eq "mobile" || ($main::mode =~ /mobile/ && $main::myadmin_flag >= 5)){
		main::kget_items();
		$plustype_ranking .= qq( Mobile-view); 
	}
	else{
		$plustype_ranking .= qq( Desktop-view); 
	}



	# �\�����[�h�̒�`
	# �����t�@�C��
	if($year && $monthf){
		$main::sub_title = qq($year�N$monthf���̎Q�������L���O | $main::title);
		$main::head_link3 = qq(&gt; <a href="./ranking.html">�Q�������L���O</a>);
		$main::head_link4 = qq(&gt; $year�N$monthf��);
		$page_title = qq(<a href="./">$main::title</a> �̎Q�������L���O ( $year�N$monthf�� ));
		$plustype_ranking .= qq( Month-file);
		$file_type = "month";
	}
	# �ŋ߂̃t�@�C��
	elsif($year eq "news"){
		$main::sub_title = qq(�ŋ߂̎Q���� | $main::title);
		$main::head_link3 = qq(&gt; <a href="./ranking.html">�Q�������L���O</a>);
		$main::head_link4 = qq(&gt; �ŋ߂̎Q����);
		$page_title = qq(<a href="./">$main::title</a> / �ŋ߂̎Q����);
		$plustype_ranking .= qq( News-file);
		$file_type = "news";
	}
	# �����t�@�C��
	else{
		$main::sub_title = qq(�Q�������L���O | $main::title);
		$main::head_link3 = qq(&gt; �Q�������L���O);
		$page_title = qq(<a href="./">$main::title</a> �̎Q�������L���O ( �S���� ));
		$plustype_ranking .= qq( All-file);
		$file_type = "all";
	}

# �����L���O�f�[�^���擾
my($index_line) = Mebius::BBS::HandleRankingBBS("Get-index $plustype_ranking",$main::moto,$year,$monthf);

	# ���m���Ŏ��������N�؂�`�F�b�N
	if(rand(20) < 1 || $main::alocal_mode){
		Mebius::BBS::HandleRankingBBS("Dead-link-check Renew $plustype_ranking",$main::moto,$year,$monthf);
	}

# ���j�����N���`
$history_line .= qq(<h2$main::kstyle_h2>���j���[</h2>\n);
	if($file_type eq "news"){ $history_line .= qq(�ŋ�\n); }
	else{ $history_line .= qq(<a href="./ranking-news.html">�ŋ�</a>\n); }
	if($file_type eq "all"){ $history_line .= qq(�S����\n); }
	else{ $history_line .= qq(<a href="./ranking.html">�S����</a>\n); }
($history_line) .= Mebius::BBS::HandleRankingHistoryBBS("Get-index $plustype_ranking",$main::moto,$year,$monthf);


# HTML
my $print = qq(
<div>
<h1$main::kstyle_h1>$page_title</h1>
<h2$main::kstyle_h2>�ꗗ</h2>
$index_line
$history_line
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
