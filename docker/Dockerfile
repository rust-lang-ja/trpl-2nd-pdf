FROM ubuntu:22.04

LABEL maintainer="YOSHIMRUA Hikaru <yyu [at] mental.poker>"

ARG TARGETARCH

RUN apt-get update

ENV PERSISTENT_DEPS \
    python3-pip \
    build-essential \
    curl \
    make \
    perl \
    ghostscript \
    inkscape \
    bash \
    git \
    lz4 \
    ca-certificates \
    unzip \
    fontconfig
RUN apt-get install -y --no-install-recommends $PERSISTENT_DEPS

# Setup fonts
ENV FONT_PATH /usr/share/fonts/
RUN mkdir -p $FONT_PATH && \
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
    fc-cache -f -v

# Install Pandoc
ENV PANDOC_VERSION 2.19
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/pandoc-$PANDOC_VERSION-linux-$TARGETARCH.tar.gz
ENV PANDOC_ROOT /usr/local/bin/pandoc
RUN curl -sSfL "$PANDOC_DOWNLOAD_URL" | tar -xzf - && \
    cp pandoc-$PANDOC_VERSION/bin/pandoc $PANDOC_ROOT && \
    rm -Rf pandoc-$PANDOC_VERSION/

# Install Pandocfilter
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

# Update Rust and cargo
ENV RUST_VERSION stable
ENV PATH /root/.cargo/bin:$PATH
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain $RUST_VERSION && \
    rustup update

# Install mdBook
RUN cargo install mdbook

# Install TeXLive
ARG TEXLIVE_OPTIONS=""
ENV TEXLIVE_PATH /usr/local/texlive
RUN mkdir /tmp/install-tl-unx && \
    curl -sSfL http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
      tar -xz -C /tmp/install-tl-unx --strip-components=1 && \
    printf "%s\n" \
      "TEXDIR $TEXLIVE_PATH" \
      "selected_scheme scheme-small" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/install-tl-unx/texlive.profile && \
    if [[ "$TARGETARCH" = "arm64" ]]; then \
      /tmp/install-tl-unx/install-tl \
        -profile /tmp/install-tl-unx/texlive.profile \
        $TEXLIVE_OPTIONS \
        -force-platform aarch64-linux; \
    else \
      /tmp/install-tl-unx/install-tl \
        -profile /tmp/install-tl-unx/texlive.profile \
        $TEXLIVE_OPTIONS; \
    fi

ENV PATH $TEXLIVE_PATH/bin/aarch64-linux:$TEXLIVE_PATH/bin/x86_64-linux:/bin:$PATH
RUN tlmgr install latexmk collection-luatex collection-langjapanese \
      collection-fontsrecommended type1cm mdframed needspace fncychap \
      everyhook svn-prov enumitem background everypage zref && \
    luaotfload-tool -u -vvv && \
    rm -fr /tmp/install-tl-unx && \
    apt-get -y clean

VOLUME ["/workdir", "/root/.cargo"]

WORKDIR /workdir

ENTRYPOINT ["/bin/bash", "-c", "./setup.sh && make"]
