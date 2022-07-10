FROM alpine:3.16

LABEL maintainer="YOSHIMRUA Hikaru <yyu [at] mental.poker>"

ENV TEXLIVE_DEPS \
    xz \
    tar \
    fontconfig-dev \
    zlib-dev \
    gnupg \
    musl-dev \
    alpine-sdk \
    pkgconfig \
    gmp-dev

ENV TEXLIVE_PATH /usr/local/texlive

ENV FONT_DEPS \
    unzip \
    fontconfig-dev

ENV FONT_PATH /usr/share/fonts/

ARG TARGETARCH

ENV PANDOC_VERSION 2.18
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/pandoc-$PANDOC_VERSION-linux-$TARGETARCH.tar.gz
ENV PANDOC_ROOT /usr/local/bin/pandoc

ENV PERSISTENT_DEPS \
    py-pip \
    rust \
    cargo \
    curl \
    make \
    perl \
    ghostscript \
    inkscape \
    bash \
    git \
    ca-certificates

ENV PATH $TEXLIVE_PATH/bin/x86_64-linux:$TEXLIVE_PATH/bin/x86_64-linuxmusl:/root/.cargo/bin:$PATH

RUN apk upgrade --update

# Install basic dependencies
RUN apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS

# Setup fonts
RUN mkdir -p $FONT_PATH && \
    apk add --no-cache --virtual .font-deps $FONT_DEPS && \
    # Noto Serif
    curl -sSfLO https://noto-website-2.storage.googleapis.com/pkgs/NotoSerif-unhinted.zip && \
      unzip -d NotoSerif-unhinted NotoSerif-unhinted.zip && \
      cp NotoSerif-unhinted/*.ttf $FONT_PATH && \
      rm -rf NotoSerif-unhinted.zip NotoSerif-unhinted && \
    # Noto Naskh Arabic
    curl -sSfLO https://noto-website-2.storage.googleapis.com/pkgs/NotoNaskhArabic-unhinted.zip && \
      unzip -d NotoNaskhArabic-unhinted NotoNaskhArabic-unhinted.zip && \
      cp NotoNaskhArabic-unhinted/*.ttf $FONT_PATH && \
      rm -rf NotoNaskhArabic-unhinted.zip NotoNaskhArabic-unhinted && \
    # Noto Serif CJK JP
    curl -sSfLO https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKjp-hinted.zip && \
      unzip -d NotoSerifCJKjp-hinted NotoSerifCJKjp-hinted.zip && \
      cp NotoSerifCJKjp-hinted/*.otf $FONT_PATH && \
      rm -rf NotoSerifCJKjp-hinted.zip NotoSerifCJKjp-hinted && \
    # Noto Sans Devanagari
    curl -sSfLO https://noto-website-2.storage.googleapis.com/pkgs/NotoSansDevanagari-unhinted.zip && \
      unzip -d NotoSansDevanagari-unhinted NotoSansDevanagari-unhinted.zip && \
      cp NotoSansDevanagari-unhinted/*.ttf $FONT_PATH && \
      rm -rf NotoSansDevanagari-unhinted.zip NotoSansDevanagari-unhinted && \
    # Noto Emoji
    curl -sSfLO https://noto-website-2.storage.googleapis.com/pkgs/NotoEmoji-unhinted.zip && \
      unzip -d NotoEmoji-unhinted NotoEmoji-unhinted.zip && \
      cp NotoEmoji-unhinted/*.ttf $FONT_PATH && \
      rm -rf NotoEmoji-unhinted.zip  NotoEmoji-unhinted && \
    # Noto Sans Hebrew
    curl -sSfLO https://noto-website-2.storage.googleapis.com/pkgs/NotoSansHebrew-unhinted.zip && \
      unzip -d NotoSansHebrew-unhinted NotoSansHebrew-unhinted.zip && \
      cp NotoSansHebrew-unhinted/*.ttf $FONT_PATH && \
      rm -rf NotoSansHebrew-unhinted.zip NotoSansHebrew-unhinted && \
    # Source Code Pro
    curl -sSfLO "https://github.com/adobe-fonts/source-code-pro/releases/download/2.038R-ro%2F1.058R-it%2F1.018R-VAR/OTF-source-code-pro-2.038R-ro-1.058R-it.zip" && \
      unzip OTF-source-code-pro-2.038R-ro-1.058R-it.zip -d source-code-pro && \
      cp source-code-pro/*.otf $FONT_PATH && \
      rm -rf OTF-source-code-pro-2.038R-ro-1.058R-it.zip source-code-pro && \
    fc-cache -f -v && \
    apk del .font-deps 

# Install Pandoc
RUN wget -qO- "$PANDOC_DOWNLOAD_URL" | tar -xzf - && \
    cp pandoc-$PANDOC_VERSION/bin/pandoc $PANDOC_ROOT && \
    rm -Rf pandoc-$PANDOC_VERSION/

# Install Pandocfilter
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

# Update Rust and cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    rustup update

# Install mdBook
RUN cargo install mdbook

# Install TeXLive
RUN apk add --no-cache --virtual .texlive-deps $TEXLIVE_DEPS && \
    mkdir /tmp/install-tl-unx && \
    curl -sSfL http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
      tar -xz -C /tmp/install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "TEXDIR $TEXLIVE_PATH" \
      "selected_scheme scheme-small" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/install-tl-unx/texlive.profile && \
    /tmp/install-tl-unx/install-tl \
      -profile /tmp/install-tl-unx/texlive.profile && \
    tlmgr install latexmk collection-luatex collection-langjapanese \
      collection-fontsrecommended type1cm mdframed needspace fncychap \
      everyhook svn-prov enumitem background everypage zref && \
    luaotfload-tool -v -vvv -u && \
    rm -fr /tmp/install-tl-unx && \
    apk del .texlive-deps

VOLUME ["/workdir"]

WORKDIR /workdir

ENTRYPOINT ["/bin/bash", "-c", "./setup.sh && make"]
