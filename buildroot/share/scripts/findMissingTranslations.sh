#!/usr/bin/env bash
#
# findMissingTranslations.sh
#
# Locate all language strings needing an update based on English
#
# Usage: findMissingTranslations.sh [language codes]
#
# If no language codes are specified then all languages will be checked
#

[ -d "Marlin" ] && cd "Marlin"

FILES=$(ls language_*.h | grep -v -E "(_en|_test)\.h" | sed -E 's/language_([^\.]+)\.h/\1/')
declare -A STRING_MAP

# Get files matching the given arguments
TEST_LANGS=$FILES
if [[ -n $@ ]]; then
  TEST_LANGS=""
  for K in "$@"; do
    for F in $FILES; do
      [[ "$F" != "${F%$K*}" ]] && TEST_LANGS="$TEST_LANGS $F"
    done
  done
fi

echo -n "Building list of missing strings..."

for i in $(awk '/#ifndef/{print $2}' language_en.h); do
  [[ $i == "LANGUAGE_EN_H" ]] && continue
  LANG_LIST=""
  for j in $TEST_LANGS; do
    [[ $(grep -c " ${i} " language_${j}.h) -eq 0 ]] && LANG_LIST="$LANG_LIST $j"
  done
  [[ -z $LANG_LIST ]] && continue
  STRING_MAP[$i]=$LANG_LIST
done

echo

for K in $( printf "%s\n" "${!STRING_MAP[@]}" | sort ); do
  printf "%-35s :%s\n" "$K" "${STRING_MAP[$K]}"
done
