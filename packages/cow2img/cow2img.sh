cowfiles="@cowfiles@"
tape="@tape@"

# Util
rstrip() {
	printf '%s\n' "${1%%$2}"
}

# Options
opt_help=false
opt_message=
opt_pick=
opt_cow=

missing_opt_value() {
	echo "Option $1 requires a value."
	exit 1
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			opt_help=true
			shift
			;;
		-c|--cow)
			if [ -z "${2:-}" ]; then
				missing_opt_value $1
			fi

			opt_cow="$2"
			shift 2
			;;
		-m|--message)
			if [ -z "${2:-}" ]; then
				missing_opt_value $1
			fi

			opt_message="$2"
			shift 2
			;;
		-p|--pick)
			opt_pick=true
			shift
			;;
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			echo "Unknown argument $1"
			exit 1
			;;
	esac
done

if [ "${opt_help}" == "true" ]; then
		echo "
cow2img

USAGE

  cow2img [options]

OPTIONS

  -h, --help              Show this help message
  -c, --cow <cowfile>     Use a specific cow file
  -m, --message <text>    Use a specific message
  -p, --pick              Pick a cow from a list

EXAMPLES

  $ # Render a random cow and quote.
  $ cow2img

  $ # Render a cow with a specific message.
  $ cow2img --message \"Hello, World!\"

  $ # Render a specific cow.
  $ cow2img --cow ./my.cow

  $ # Pick a cow.
  $ cow2img --pick
		"
    exit 0
fi

if [ "${opt_pick}" == "true" ]; then
	all_cows=($cowfiles/cows/*.cow)
	cow_names=""

	for cow in "${all_cows[@]}"; do
		file_name=$(basename $cow)
		cow_names="$cow_names"$'\n'"$(rstrip "$file_name" ".cow")"
	done

	cow_name=$(echo "${cow_names}" | gum filter \
		--prompt="Pick Cow: " \
		--limit=1 \
		--indicator.foreground="4" \
		--match.foreground="4" \
		--selected-indicator.foreground="4"
	)
	cow=$cowfiles/cows/$cow_name.cow
elif [ -z "${opt_cow}" ]; then
	# Pick a random cow.
	all_cows=($cowfiles/cows/*.cow)
	total_cows=$(ls $cowfiles/cows/*.cow | wc -l)
	cow_index=$(($RANDOM % $total_cows))
	cow="${all_cows[$cow_index]}"
else
	cow="${opt_cow}"
fi

if [ -z "${opt_message}" ]; then
	# Get a message.
	message=$(fortune)
else
	message="${opt_message}"
fi

# Render the cow as text.
rendered_cow=$(echo -n "$message" | cowsay -f "$cow")

# Calculate the dimensions of the rendered cow + message. From these values,
# we'll figure out the pixel values to crop the image to.
cow_width=0
cow_height=0
while IFS= read -r line; do
	cow_height=$(($cow_height + 1))

	# Most cows we use are full of color sequences which mess with the count wc performs.
	raw_line=$(echo -n "$line" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g")

	line_length=$(echo -n -e "$raw_line" | wc -c)

	if [[ $line_length -gt $cow_width ]]; then
		cow_width=$line_length
	fi
done <<< "$rendered_cow"

# Render with VHS.
temp=$(mktemp -d)
pushd $temp > /dev/null
	echo "$rendered_cow" > cow
	gum spin --title "Rendering" --spinner.foreground="4" -- vhs $tape
popd > /dev/null

# Bash doesn't support multiplication with floats, so we have to use `bc`.
crop_width=$(echo "$cow_width*9" | bc)
crop_height=$(echo "$cow_height*18.5" | bc)

# Create and clean the `cow` directory.
mkdir -p cow/
rm -rf cow/*

# Crop the image and give it a border.
convert $temp/frames/frame-text-00001.png \
	-crop ${crop_width}x${crop_height}+0+0 \
	-bordercolor "#2e3440" \
	-border 32x32 \
	./cow/image.png

# Write data needed for alt text (if desired).
echo "$message" > ./cow/message
echo "$(rstrip $(basename $cow) ".cow")" > ./cow/name

# Cleanup
rm -rf $temp
