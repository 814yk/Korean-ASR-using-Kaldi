#!/bin/bash

# Copyright 2017.08.09 sanghong.kim@inha.ac.kr
#           2014~2017  Department of Electronic Engineering at the Inha University
#           Korean Speech recognition
#
#	DSP Lab. sanghongkim
#	Based on the code written by hyungwon yang
#	URL: http://hyungwonsnotebook.blogspot.kr/2016/11/korean-automatic-speech-recognition_5.html

# open path.sh then, set your kaldi path

. ./path.sh || exit 1

rm ./utils ./steps

ln -s $KALDI_ROOT/egs/wsj/s5/utils ./utils
ln -s $KALDI_ROOT/egs/wsj/s5/steps ./steps





# Set command what you want to use Ex) utils/run.pl, utils/queue.pl
train_cmd=utils/run.pl
test_cmd=utils/run.pl
# Data Directory
train_dir=data/train
test_dir=data/test
dict_dir=data/local/dict
lang_dir=data/local/lang

# Set variables
#
#		ex
#	train_nj=5
#

train_nj=8
test_nj=8
# if you want decode background, set decodebg=1 and if this is first time, set copyscripts=1

#if [ $copyscripts -eq 1 ];thetn
#	local/make_script.sh \
#		$src
#fi



# train triphone system
  if $train; then
    steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
      data/train data/local/lang exp/mono exp/mono_ali || exit 1;

    steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" 2000 10000 \
      data/train data/local/lang exp/mono_ali exp/tri || exit 1;

  fi

  if $decode; then
    utils/mkgraph.sh data/lang \
      exp/tri exp/tri/graph || exit 1;

    for data in  train test; do
      nspk=$(wc -l <data/${data}/spk2utt)
      steps/decode.sh --nj $nspk --cmd "$decode_cmd" exp/tri/graph \
        data/${data} exp/tri/decode_${data} || exit 1;

      # later on we'll demonstrate const-arpa LM rescoring, which is now
      # the recommended method.
    done

    ## the following command demonstrates how to get lattices that are
    ## "word-aligned" (arcs coincide with words, with boundaries in the right
    ## place).
    #sil_label=`grep '!SIL' data/lang_nosp_test_tgpr/words.txt | awk '{print $2}'`
    #steps/word_align_lattices.sh --cmd "$train_cmd" --silence-label $sil_label \
    #  data/lang_nosp_test_tgpr exp/tri1/decode_nosp_tgpr_dev93 \
    #  exp/tri1/decode_nosp_tgpr_dev93_aligned || exit 1;
  fi

