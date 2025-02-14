#!/bin/bash
set -e

# --- 引数のチェック ---
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <destination_directory>"
    exit 1
fi

DEST_DIR="$1"

# 指定されたパスが存在していて、ディレクトリでない場合はエラー
if [ -e "$DEST_DIR" ] && [ ! -d "$DEST_DIR" ]; then
    echo "エラー: '$DEST_DIR' は既に存在していますが、ディレクトリではありません。"
    exit 1
fi

# 統合先ディレクトリが存在しなければ作成
mkdir -p "$DEST_DIR"

echo "統合先ディレクトリ: $DEST_DIR"
echo "--------------------------------"

# --- Takeout* ディレクトリの処理 ---
# カレントディレクトリ直下の "Takeout*" ディレクトリを対象にループ
for takeout in Takeout*; do
    # ディレクトリでなければスキップ
    if [[ ! -d "$takeout" ]]; then
        continue
    fi

    echo "処理中: $takeout"

    # "Google フォト" ディレクトリが存在する場合に限定
    if [[ -d "$takeout/Google フォト" ]]; then
        # "Google フォト" 内の "Photos from ～" ディレクトリを探す
        for photo_dir in "$takeout/Google フォト"/*; do
            # 該当パスが存在し、かつディレクトリであるかを確認
            if [[ -d "$photo_dir" ]]; then
                base=$(basename "$photo_dir")  # 例: "Photos from 2023"
                mkdir -p "$DEST_DIR/$base"

                echo "  → '$base' の中身を '$DEST_DIR/$base/' へ移動します。（.json ファイルは除外）"
                # ファイルやサブディレクトリを移動（.json ファイルは除外）
                for item in "$photo_dir"/*; do
                    # 存在しない場合（空ディレクトリ）をチェック
                    if [ ! -e "$item" ]; then
                        continue
                    fi
                    if [[ "$item" == *.json ]]; then
                      #  echo "    スキップ: $(basename "$item") (json file)"
                        continue
                    fi
                    mv "$item" "$DEST_DIR/$base/" 2>/dev/null || true
                done

                # 移動後、空になったディレクトリは削除
                rmdir "$photo_dir" 2>/dev/null || true
            fi
        done
    else
        echo "  ※ '$takeout' 内に 'Google フォト' ディレクトリが見つかりません。"
    fi

    # Takeout* ディレクトリごと削除
    echo "  → '$takeout' を削除します。"
    rm -rf "$takeout"
    echo "--------------------------------"
done

echo "整理完了!"
