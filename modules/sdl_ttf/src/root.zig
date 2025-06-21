const std = @import("std");
const sdl = @import("sdl");

/// A text engine used to create text objects.
///
/// This is a public interface that can be used by applications and libraries
/// to perform customize rendering with text objects. See
/// <SDL3_ttf/SDL_textengine.h> for details.
///
/// There are three text engines provided with the library:
///
/// - Drawing to an SDL_Surface, created with TTF_CreateSurfaceTextEngine()
/// - Drawing with an SDL 2D renderer, created with
///   TTF_CreateRendererTextEngine()
/// - Drawing with the SDL GPU API, created with TTF_CreateGPUTextEngine()
///
/// \since This struct is available since SDL_ttf 3.0.0.
pub const TextEngine = @import("textengine.zig").TextEngine;

pub const init = TTF_Init;

pub fn fontOpen(path: [:0]const u8, ptsize: f32) !*Font {
    if (TTF_OpenFont(path.ptr, ptsize)) |font| {
        return font;
    } else {
        sdl.log("Error opening font: %s", sdl.getError());
        return error.SdlError;
    }
}

pub const version = TTF_Version;
pub const versionHarfBuzz = TTF_GetHarfBuzzVersion;
pub const versionFreeType = TTF_GetFreeTypeVersion;
pub const fontOpenIO = TTF_OpenFontIO;
pub const fontOpenWithProperties = TTF_OpenFontWithProperties;
pub const quit = TTF_Quit;
pub const wasInit = TTF_WasInit;

pub const Font = opaque {
    pub const copy = TTF_CopyFont;
    pub const properties = TTF_GetFontProperties;
    pub const generation = TTF_GetFontGeneration;
    pub const fallbackAdd = TTF_AddFallbackFont;
    pub const fallbackRemove = TTF_RemoveFallbackFont;
    pub const fallbackClear = TTF_ClearFallbackFonts;
    pub const sizeSet = TTF_SetFontSize;
    pub const sizeSetDpi = TTF_SetFontSizeDPI;
    pub const size = TTF_GetFontSize;
    pub const dpi = TTF_GetFontDPI;
    pub const styleSet = TTF_SetFontStyle;
    pub const style = TTF_GetFontStyle;
    pub const outlineSet = TTF_SetFontStyle;
    pub const outline = TTF_GetFontOutline;
    pub const hintingSet = TTF_SetFontHinting;
    pub const numFaces = TTF_GetNumFontFaces;
    pub const hinting = TTF_GetFontHinting;

    pub fn sdfSet(font: *Font, enabled: bool) !void {
        if (!TTF_SetFontSDF(font, enabled)) {
            sdl.log("TTF_SetFontSDF error: %s", sdl.getError());
            return error.SdlError;
        }
    }

    pub const sdf = TTF_GetFontSDF;
    pub const weight = TTF_GetFontWeight;
    pub const wrapAlignmentSet = TTF_SetFontWrapAlignment;
    pub const wrapAlignment = TTF_GetFontWrapAlignment;
    pub const height = TTF_GetFontHeight;
    pub const ascent = TTF_GetFontAscent;
    pub const descent = TTF_GetFontDescent;
    pub const lineSkipSet = TTF_SetFontLineSkip;
    pub const lineSkip = TTF_GetFontLineSkip;
    pub const kerningSet = TTF_SetFontKerning;
    pub const kerning = TTF_GetFontKerning;
    pub const isFixedWidth = TTF_FontIsFixedWidth;
    pub const isScalable = TTF_FontIsScalable;
    pub const familyName = TTF_GetFontFamilyName;
    pub const styleName = TTF_GetFontStyleName;
    pub const directionSet = TTF_SetFontDirection;
    pub const direction = TTF_GetFontDirection;
    pub const stringToTag = TTF_StringToTag;
    pub const tagToString = TTF_TagToString;
    pub const scriptSet = TTF_SetFontScript;
    pub const script = TTF_GetFontScript;
    pub const glyphScript = TTF_GetGlyphScript;
    pub const languageSet = TTF_SetFontLanguage;
    pub const hasGlyph = TTF_FontHasGlyph;
    pub const glyphImage = TTF_GetGlyphImage;
    pub const glyphImageForIndex = TTF_GetGlyphImageForIndex;
    pub const glyphMetrics = TTF_GetGlyphMetrics;
    pub const glyphKerning = TTF_GetGlyphKerning;
    pub const stringSize = TTF_GetStringSize;
    pub const stringSizeWrapped = TTF_GetStringSizeWrapped;
    pub const stringMeasure = TTF_MeasureString;
    pub const renderTextSolid = TTF_RenderText_Solid;
    pub const renderTextSolidWrapped = TTF_RenderText_Solid_Wrapped;
    pub const renderGlyphSolid = TTF_RenderGlyph_Solid;
    pub const renderTextShaded = TTF_RenderText_Shaded;
    pub const renderTextShadedWrapped = TTF_RenderText_Shaded_Wrapped;
    pub const renderGlyphShaded = TTF_RenderGlyph_Shaded;
    pub const renderTextBlended = TTF_RenderText_Blended;
    pub const renderTextBlendedWrapped = TTF_RenderText_Blended_Wrapped;
    pub const renderGlyphBlended = TTF_RenderGlyph_Blended;
    pub const renderTextLcd = TTF_RenderText_LCD;
    pub const renderTextLcdWrapped = TTF_RenderText_LCD_Wrapped;
    pub const renderGlyphLcd = TTF_RenderGlyph_LCD;
    pub const close = TTF_CloseFont;
};

const FontStyleFlags = packed struct(u32) {
    normal: bool = false, // **< No special style */
    bold: bool = false, // **< Bold style */
    italic: bool = false, // **< Italic style */
    underline: bool = false, // **< Underlined text */
    strikethrough: bool = false, // **< Strikethrough text */
    padding: u27 = 0,
};

pub const Properties = struct {
    pub const create_filename_string = "SDL_ttf.font.create.filename";
    pub const create_iostream_pointer = "SDL_ttf.font.create.iostream";
    pub const create_iostream_offset_number = "SDL_ttf.font.create.iostream.offset";
    pub const create_iostream_autoclose_boolean = "SDL_ttf.font.create.iostream.autoclose";
    pub const create_size_float = "SDL_ttf.font.create.size";
    pub const create_face_number = "SDL_ttf.font.create.face";
    pub const create_horizontal_dpi_number = "SDL_ttf.font.create.hdpi";
    pub const create_vertical_dpi_number = "SDL_ttf.font.create.vdpi";
    pub const create_existing_font_pointer = "SDL_ttf.font.create.existing_font";
    pub const outline_line_cap_number = "SDL_ttf.font.outline.line_cap";
    pub const outline_line_join_number = "SDL_ttf.font.outline.line_join";
    pub const outline_miter_limit_number = "SDL_ttf.font.outline.miter_limit";
    pub const renderer_text_engine_renderer_pointer = "SDL_ttf.renderer_text_engine.create.renderer";
    pub const renderer_text_engine_atlas_texture_size_number = "SDL_ttf.renderer_text_engine.create.atlas_texture_size";
    pub const gpu_text_engine_device_pointer = "SDL_ttf.gpu_text_engine.create.device";
    pub const gpu_text_engine_atlas_texture_size_number = "SDL_ttf.gpu_text_engine.create.atlas_texture_size";
};

/// This function gets the version of the dynamically linked SDL_ttf library.
///
/// \returns SDL_ttf version.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_Version() c_int;

/// Query the version of the FreeType library in use.
///
/// TTF_Init() should be called before calling this function.
///
/// \param major to be filled in with the major version number. Can be NULL.
/// \param minor to be filled in with the minor version number. Can be NULL.
/// \param patch to be filled in with the param version number. Can be NULL.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_Init
extern fn TTF_GetFreeTypeVersion(major: *c_int, minor: *c_int, patch: *c_int) void;

/// Query the version of the HarfBuzz library in use.
///
/// If HarfBuzz is not available, the version reported is 0.0.0.
///
/// \param major to be filled in with the major version number. Can be NULL.
/// \param minor to be filled in with the minor version number. Can be NULL.
/// \param patch to be filled in with the param version number. Can be NULL.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetHarfBuzzVersion(major: *c_int, minor: *c_int, patch: *c_int) void;

/// Initialize SDL_ttf.
///
/// You must successfully call this function before it is safe to call any
/// other function in this library.
///
/// It is safe to call this more than once, and each successful TTF_Init() call
/// should be paired with a matching TTF_Quit() call.
///
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_Quit
extern fn TTF_Init() bool;

/// Create a font from a file, using a specified posize: c_int.
///
/// Some .fon fonts will have several sizes embedded in the file, so the point
/// size becomes the index of choosing which size. If the value is too high,
/// the last indexed size will be the default.
///
/// When done with the returned TTF_Font, use TTF_CloseFont() to dispose of it.
///
/// \param file path to font file.
/// \param ptsize posize: c_int to use for the newly-opened font.
/// \returns a valid TTF_Font, or NULL on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CloseFont
extern fn TTF_OpenFont(file: [*:0]const u8, ptsize: f32) ?*Font;

/// Create a font from an SDL_IOStream, using a specified posize: c_int.
///
/// Some .fon fonts will have several sizes embedded in the file, so the point
/// size becomes the index of choosing which size. If the value is too high,
/// the last indexed size will be the default.
///
/// If `closeio` is true, `src` will be automatically closed once the font is
/// closed. Otherwise you should keep `src` open until the font is closed.
///
/// When done with the returned TTF_Font, use TTF_CloseFont() to dispose of it.
///
/// \param src an SDL_IOStream to provide a font file's data.
/// \param closeio true to close `src` when the font is closed, false to leave
///                it open.
/// \param ptsize posize: c_int to use for the newly-opened font.
/// \returns a valid TTF_Font, or NULL on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CloseFont
extern fn TTF_OpenFontIO(src: *sdl.iostream.Stream, closeio: bool, ptsize: f32) ?*Font;

/// Create a font with the specified properties.
///
/// These are the supported properties:
///
/// - `TTF_PROP_FONT_CREATE_FILENAME_STRING`: the font file to open, if an
///   SDL_IOStream isn't being used. This is required if
///   `TTF_PROP_FONT_CREATE_IOSTREAM_POINTER` and
///   `TTF_PROP_FONT_CREATE_EXISTING_FONT_POINTER` aren't set.
/// - `TTF_PROP_FONT_CREATE_IOSTREAM_POINTER`: an SDL_IOStream containing the
///   font to be opened. This should not be closed until the font is closed.
///   This is required if `TTF_PROP_FONT_CREATE_FILENAME_STRING` and
///   `TTF_PROP_FONT_CREATE_EXISTING_FONT_POINTER` aren't set.
/// - `TTF_PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER`: the offset in the iostream
///   for the beginning of the font, defaults to 0.
/// - `TTF_PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN`: true if closing the
///   font should also close the associated SDL_IOStream.
/// - `TTF_PROP_FONT_CREATE_SIZE_FLOAT`: the posize: c_int of the font. Some .fon
///   fonts will have several sizes embedded in the file, so the posize: c_int
///   becomes the index of choosing which size. If the value is too high, the
///   last indexed size will be the default.
/// - `TTF_PROP_FONT_CREATE_FACE_NUMBER`: the face index of the font, if the
///   font contains multiple font faces.
/// - `TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER`: the horizontal DPI to use
///   for font rendering, defaults to
///   `TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER` if set, or 72 otherwise.
/// - `TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER`: the vertical DPI to use for
///   font rendering, defaults to `TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER`
///   if set, or 72 otherwise.
/// - `TTF_PROP_FONT_CREATE_EXISTING_FONT_POINTER`: an optional TTF_Font that,
///   if set, will be used as the font data source and the initial size and
///   style of the new font.
///
/// \param props the properties to use.
/// \returns a valid TTF_Font, or NULL on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CloseFont
extern fn TTF_OpenFontWithProperties(sdl.PropertiesID) ?*Font;

///  Create a copy of an existing font.
///
///  The copy will be distinct from the original, but will share the font file
///  and have the same size and style as the original.
///
///  When done with the returned TTF_Font, use TTF_CloseFont() to dispose of it.
///
///  \param existing_font the font to copy.
///  \returns a valid TTF_Font, or NULL on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                original font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_CloseFont
extern fn TTF_CopyFont(existing_font: *Font) ?*Font;

///  Get the properties associated with a font.
///
///  The following read-write properties are provided by SDL:
///
///  - `TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER`: The FT_Stroker_LineCap value
///    used when setting the font outline, defaults to
///    `FT_STROKER_LINECAP_ROUND`.
///  - `TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER`: The FT_Stroker_LineJoin value
///    used when setting the font outline, defaults to
///    `FT_STROKER_LINEJOIN_ROUND`.
///  - `TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER`: The FT_Fixed miter limit used
///    when setting the font outline, defaults to 0.
///
///  \param font the font to query.
///  \returns a valid property ID on success or 0 on failure; call
///           SDL_GetError() for more information.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontProperties(font: *Font) sdl.PropertiesID;

///  Get the font generation.
///
///  The generation is incremented each time font properties change that require
///  rebuilding glyphs, such as style, size, etc.
///
///  \param font the font to query.
///  \returns the font generation or 0 on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontGeneration(font: *Font) u32;

///  Add a fallback font.
///
///  Add a font that will be used for glyphs that are not in the current font.
///  The fallback font should have the same size and style as the current font.
///
///  If there are multiple fallback fonts, they are used in the order added.
///
///  This updates any TTF_Text objects using this font.
///
///  \param font the font to modify.
///  \param fallback the font to add as a fallback.
///  \returns true on success or false on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created
///                both fonts.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_ClearFallbackFonts
///  \sa TTF_RemoveFallbackFont
extern fn TTF_AddFallbackFont(font: *Font, fallback: *Font) bool;

///  Remove a fallback font.
///
///  This updates any TTF_Text objects using this font.
///
///  \param font the font to modify.
///  \param fallback the font to remove as a fallback.
///
///  \threadsafety This function should be called on the thread that created
///                both fonts.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_AddFallbackFont
///  \sa TTF_ClearFallbackFonts
extern fn TTF_RemoveFallbackFont(font: *Font, fallback: *Font) void;

///  Remove all fallback fonts.
///
///  This updates any TTF_Text objects using this font.
///
///  \param font the font to modify.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_AddFallbackFont
///  \sa TTF_RemoveFallbackFont
extern fn TTF_ClearFallbackFonts(font: *Font) void;

///  Set a font's size dynamically.
///
///  This updates any TTF_Text objects using this font, and clears
///  already-generated glyphs, if any, from the cache.
///
///  \param font the font to resize.
///  \param ptsize the new posize: c_int.
///  \returns true on success or false on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontSize
extern fn TTF_SetFontSize(font: *Font, ptsize: f32) bool;

///  Set font size dynamically with target resolutions, in dots per inch.
///
///  This updates any TTF_Text objects using this font, and clears
///  already-generated glyphs, if any, from the cache.
///
///  \param font the font to resize.
///  \param ptsize the new posize: c_int.
///  \param hdpi the target horizontal DPI.
///  \param vdpi the target vertical DPI.
///  \returns true on success or false on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontSize
///  \sa TTF_GetFontSizeDPI
extern fn TTF_SetFontSizeDPI(font: *Font, ptsize: f32, htpi: c_int, vdpi: c_int) bool;

///  Get the size of a font.
///
///  \param font the font to query.
///  \returns the size of the font, or 0.0f on failure; call SDL_GetError() for
///           more information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontSize
///  \sa TTF_SetFontSizeDPI
extern fn TTF_GetFontSize(font: *Font) f32;

///  Get font target resolutions, in dots per inch.
///
///  \param font the font to query.
///  \param hdpi a pointer filled in with the target horizontal DPI.
///  \param vdpi a pointer filled in with the target vertical DPI.
///  \returns true on success or false on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontSizeDPI
extern fn TTF_GetFontDPI(font: *Font, hdpi: *c_int, vdpi: *c_int) bool;

///  Font style flags for TTF_Font
///
///  These are the flags which can be used to set the style of a font in
///  SDL_ttf. A combination of these flags can be used with functions that set
///  or query font style, such as TTF_SetFontStyle or TTF_GetFontStyle.
///
///  \since This datatype is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontStyle
///  \sa TTF_GetFontStyle
///  Set a font's current style.
///
///  This updates any TTF_Text objects using this font, and clears
///  already-generated glyphs, if any, from the cache.
///
///  The font styles are a set of bit flags, OR'd together:
///
///  - `TTF_STYLE_NORMAL` (is zero)
///  - `TTF_STYLE_BOLD`
///  - `TTF_STYLE_ITALIC`
///  - `TTF_STYLE_UNDERLINE`
///  - `TTF_STYLE_STRIKETHROUGH`
///
///  \param font the font to set a new style on.
///  \param style the new style values to set, OR'd together.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontStyle
extern fn TTF_SetFontStyle(font: *Font, style: FontStyleFlags) void;

///  Query a font's current style.
///
///  The font styles are a set of bit flags, OR'd together:
///
///  - `TTF_STYLE_NORMAL` (is zero)
///  - `TTF_STYLE_BOLD`
///  - `TTF_STYLE_ITALIC`
///  - `TTF_STYLE_UNDERLINE`
///  - `TTF_STYLE_STRIKETHROUGH`
///
///  \param font the font to query.
///  \returns the current font style, as a set of bit flags.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontStyle
extern fn TTF_GetFontStyle(font: *const Font) FontStyleFlags;

///  Set a font's current outline.
///
///  This uses the font properties `TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER`,
///  `TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER`, and
///  `TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER` when setting the font outline.
///
///  This updates any TTF_Text objects using this font, and clears
///  already-generated glyphs, if any, from the cache.
///
///  \param font the font to set a new outline on.
///  \param outline positive outline value, 0 to default.
///  \returns true on success or false on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontOutline
extern fn TTF_SetFontOutline(font: *Font, outline: c_int) bool;

///  Query a font's current outline.
///
///  \param font the font to query.
///  \returns the font's current outline value.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontOutline
extern fn TTF_GetFontOutline(font: *Font) c_int;

///  Hinting flags for TTF (TrueType Fonts)
///
///  This enum specifies the level of hinting to be applied to the font
///  rendering. The hinting level determines how much the font's outlines are
///  adjusted for better alignment on the pixel grid.
///
///  \since This enum is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontHinting
///  \sa TTF_GetFontHinting
const HintingFlags = enum(c_int) {
    invalid = -1,
    normal, //**< Normal hinting applies standard grid-fitting. */
    light, //**< Light hinting applies subtle adjustments to improve rendering. */
    mono, //**< Monochrome hinting adjusts the font for better rendering at lower resolutions. */
    none, //**< No hinting, the font is rendered without any grid-fitting. */
    light_subpixel, //**< Light hinting with subpixel rendering for more precise font edges. */
};

///  Set a font's current hinter setting.
///
///  This updates any TTF_Text objects using this font, and clears
///  already-generated glyphs, if any, from the cache.
///
///  The hinter setting is a single value:
///
///  - `TTF_HINTING_NORMAL`
///  - `TTF_HINTING_LIGHT`
///  - `TTF_HINTING_MONO`
///  - `TTF_HINTING_NONE`
///  - `TTF_HINTING_LIGHT_SUBPIXEL` (available in SDL_ttf 3.0.0 and later)
///
///  \param font the font to set a new hinter setting on.
///  \param hinting the new hinter setting.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontHinting
extern fn TTF_SetFontHinting(font: *Font, hinting: HintingFlags) void;

///  Query the number of faces of a font.
///
///  \param font the font to query.
///  \returns the number of FreeType font faces.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetNumFontFaces(font: *Font) c_int;

///  Query a font's current FreeType hinter setting.
///
///  The hinter setting is a single value:
///
///  - `TTF_HINTING_NORMAL`
///  - `TTF_HINTING_LIGHT`
///  - `TTF_HINTING_MONO`
///  - `TTF_HINTING_NONE`
///  - `TTF_HINTING_LIGHT_SUBPIXEL` (available in SDL_ttf 3.0.0 and later)
///
///  \param font the font to query.
///  \returns the font's current hinter value, or TTF_HINTING_INVALID if the
///           font is invalid.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontHinting
extern fn TTF_GetFontHinting(font: *const Font) HintingFlags;

///  Enable Signed Distance Field rendering for a font.
///
///  SDF is a technique that helps fonts look sharp even when scaling and
///  rotating, and requires special shader support for display.
///
///  This works with Blended APIs, and generates the raw signed distance values
///  in the alpha channel of the resulting texture.
///
///  This updates any TTF_Text objects using this font, and clears
///  already-generated glyphs, if any, from the cache.
///
///  \param font the font to set SDF support on.
///  \param enabled true to enable SDF, false to disable.
///  \returns true on success or false on failure; call SDL_GetError() for more
///           information.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontSDF
extern fn TTF_SetFontSDF(font: *Font, enabled: bool) bool;

///  Query whether Signed Distance Field rendering is enabled for a font.
///
///  \param font the font to query.
///  \returns true if enabled, false otherwise.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontSDF
extern fn TTF_GetFontSDF(font: *const Font) bool;

/// Query a font's weight, in terms of the lightness/heaviness of the strokes.
///
/// \param font the font to query.
/// \returns the font's current weight.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.2.2.
extern fn TTF_GetFontWeight(font: *const Font) c_int;

pub const FontWeight = struct {
    pub const thin = 100; //*< Thin (100) named font weight value */
    pub const extra_light = 200; //*< ExtraLight (200) named font weight value */
    pub const light = 300; //*< Light (300) named font weight value */
    pub const normal = 400; //*< Normal (400) named font weight value */
    pub const medium = 500; //*< Medium (500) named font weight value */
    pub const semi_bold = 600; //*< SemiBold (600) named font weight value */
    pub const bold = 700; //*< Bold (700) named font weight value */
    pub const extra_bold = 800; //*< ExtraBold (800) named font weight value */
    pub const black = 900; //*< Black (900) named font weight value */
    pub const extra_black = 950; //*< ExtraBlack (950) named font weight value */
};

/// The horizontal alignment used when rendering wrapped text.
///
/// \since This enum is available since SDL_ttf 3.0.0.
pub const HorizontalAlignment = enum(c_int) {
    invalid = -1,
    left,
    center,
    right,
};

///  Set a font's current wrap alignment option.
///
///  This updates any TTF_Text objects using this font.
///
///  \param font the font to set a new wrap alignment option on.
///  \param align the new wrap alignment option.
///
///  \threadsafety This function should be called on the thread that created the
///                font.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_GetFontWrapAlignment
extern fn TTF_SetFontWrapAlignment(font: *Font, alignment: HorizontalAlignment) void;

///  Query a font's current wrap alignment option.
///
///  \param font the font to query.
///  \returns the font's current wrap alignment option.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
///
///  \sa TTF_SetFontWrapAlignment
extern fn TTF_GetFontWrapAlignment(font: *const Font) HorizontalAlignment;

///  Query the total height of a font.
///
///  This is usually equal to posize: c_int.
///
///  \param font the font to query.
///  \returns the font's height.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontHeight(font: *const Font) c_int;

///  Query the offset from the baseline to the top of a font.
///
///  This is a positive value, relative to the baseline.
///
///  \param font the font to query.
///  \returns the font's ascent.
///
///  \threadsafety It is safe to call this function from any thread.
///
///  \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontAscent(font: *const Font) c_int;

/// Query the offset from the baseline to the bottom of a font.
///
/// This is a negative value, relative to the baseline.
///
/// \param font the font to query.
/// \returns the font's descent.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontDescent(font: *const Font) c_int;

/// Set the spacing between lines of text for a font.
///
/// This updates any TTF_Text objects using this font.
///
/// \param font the font to modify.
/// \param lineskip the new line spacing for the font.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetFontLineSkip
extern fn TTF_SetFontLineSkip(font: *Font, lineskip: c_int) void;

/// Query the spacing between lines of text for a font.
///
/// \param font the font to query.
/// \returns the font's recommended spacing.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetFontLineSkip
extern fn TTF_GetFontLineSkip(font: *const Font) c_int;

/// Set if kerning is enabled for a font.
///
/// Newly-opened fonts default to allowing kerning. This is generally a good
/// policy unless you have a strong reason to disable it, as it tends to
/// produce better rendering (with kerning disabled, some fonts might render
/// the word `kerning` as something that looks like `keming` for example).
///
/// This updates any TTF_Text objects using this font.
///
/// \param font the font to set kerning on.
/// \param enabled true to enable kerning, false to disable.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetFontKerning
extern fn TTF_SetFontKerning(font: *Font, enabled: bool) void;

/// Query whether or not kerning is enabled for a font.
///
/// \param font the font to query.
/// \returns true if kerning is enabled, false otherwise.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetFontKerning
extern fn TTF_GetFontKerning(font: *const Font) bool;

/// Query whether a font is fixed-width.
///
/// A "fixed-width" font means all glyphs are the same width across; a
/// lowercase 'i' will be the same size across as a capital 'W', for example.
/// This is common for terminals and text editors, and other apps that treat
/// text as a grid. Most other things (WYSIWYG word processors, web pages, etc)
/// are more likely to not be fixed-width in most cases.
///
/// \param font the font to query.
/// \returns true if the font is fixed-width, false otherwise.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_FontIsFixedWidth(font: *const Font) bool;

/// Query whether a font is scalable or not.
///
/// Scalability lets us distinguish between outline and bitmap fonts.
///
/// \param font the font to query.
/// \returns true if the font is scalable, false otherwise.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetFontSDF
extern fn TTF_FontIsScalable(font: *const Font) bool;

/// Query a font's family name.
///
/// This string is dictated by thecontents of the font file.
///
/// Note that the returned string is to internal storage, and should not be
/// modified or free'd by the caller. The string becomes invalid, with the rest
/// of the font, when `font` is handed to TTF_CloseFont().
///
/// \param font the font to query.
/// \returns the font's family name.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontFamilyName(font: *const Font) [*:0]const u8;

/// Query a font's style name.
///
/// This string is dictated by the contents of the font file.
///
/// Note that the returned string is to internal storage, and should not be
/// modified or free'd by the caller. The string becomes invalid, with the rest
/// of the font, when `font` is handed to TTF_CloseFont().
///
/// \param font the font to query.
/// \returns the font's style name.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
extern fn TTF_GetFontStyleName(font: *const Font) [*:0]const u8;

/// Direction flags
///
/// The values here are chosen to match
/// [hb_direction_t](https://harfbuzz.github.io/harfbuzz-hb-common.html#hb-direction-t)
/// .
///
/// \since This enum is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetFontDirection
pub const Direction = enum(c_int) {
    invalid = 0,
    ltr = 4,
    rtl,
    ttb,
    btt,
};

/// Set the direction to be used for text shaping by a font.
///
/// This function only supports left-to-right text shaping if SDL_ttf was not
/// built with HarfBuzz support.
///
/// This updates any TTF_Text objects using this font.
///
/// \param font the font to modify.
/// \param direction the new direction for text to flow.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_SetFontDirection(font: *Font, direction: Direction) bool;

/// Get the direction to be used for text shaping by a font.
///
/// This defaults to TTF_DIRECTION_INVALID if it hasn't been set.
///
/// \param font the font to query.
/// \returns the direction to be used for text shaping.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetFontDirection(font: *Font) Direction;

/// Convert from a 4 character string to a 32-bit tag.
///
/// \param string the 4 character string to convert.
/// \returns the 32-bit representation of the string.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_TagToString
////
extern fn TTF_StringToTag(string: [*:0]const u8) u32;

/// Convert from a 32-bit tag to a 4 character string.
///
/// \param tag the 32-bit tag to convert.
/// \param string a pointer filled in with the 4 character representation of
///               the tag.
/// \param size the size of the buffer pointed at by string, should be at least
///             4.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_TagToString
////
extern fn TTF_TagToString(tag: u32, string: [*:0]u8, size: usize) void;

/// Set the script to be used for text shaping by a font.
///
/// This returns false if SDL_ttf isn't built with HarfBuzz support.
///
/// This updates any TTF_Text objects using this font.
///
/// \param font the font to modify.
/// \param script an
///               [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///               .
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_StringToTag
////
extern fn TTF_SetFontScript(font: *Font, script: u32) bool;

/// Get the script used for text shaping a font.
///
/// \param font the font to query.
/// \returns an
///          [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///          or 0 if a script hasn't been set.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_TagToString
////
extern fn TTF_GetFontScript(font: *Font) u32;

/// Get the script used by a 32-bit codepoint.
///
/// \param ch the character code to check.
/// \returns an
///          [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///          on success, or 0 on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function is thread-safe.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_TagToString
////
extern fn TTF_GetGlyphScript(ch: u32) u32;

/// Set language to be used for text shaping by a font.
///
/// If SDL_ttf was not built with HarfBuzz support, this function returns
/// false.
///
/// This updates any TTF_Text objects using this font.
///
/// \param font the font to specify a language for.
/// \param language_bcp47 a null-terminated string containing the desired
///                       language's BCP47 code. Or null to reset the value.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_SetFontLanguage(font: *Font, language_bcp47: [*:0]const u8) bool;

/// Check whether a glyph is provided by the font for a UNICODE codepoint.
///
/// \param font the font to query.
/// \param ch the codepoto: c_int check.
/// \returns true if font provides a glyph for this character, false if not.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_FontHasGlyph(font: *Font, ch: u32) bool;

/// The type of data in a glyph image
///
/// \since This enum is available since SDL_ttf 3.0.0.
////
pub const ImageType = enum(c_int) {
    invalid,
    alpha,
    color,
    sdf,
};

/// Get the pixel image for a UNICODE codepoint.
///
/// \param font the font to query.
/// \param ch the codepoto: c_int check.
/// \param image_type a pointer filled in with the glyph image type, may be
///                   NULL.
/// \returns an SDL_Surface containing the glyph, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetGlyphImage(font: *Font, ch: u32, image_type: *ImageType) ?*sdl.Surface;

/// Get the pixel image for a character index.
///
/// This is useful for text engine implementations, which can call this with
/// the `glyph_index` in a TTF_CopyOperation
///
/// \param font the font to query.
/// \param glyph_index the index of the glyph to return.
/// \param image_type a pointer filled in with the glyph image type, may be
///                   NULL.
/// \returns an SDL_Surface containing the glyph, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetGlyphImageForIndex(font: *Font, glyph_index: u32, image_type: *ImageType) ?*sdl.Surface;

/// Query the metrics (dimensions) of a font's glyph for a UNICODE codepoint.
///
/// To understand what these metrics mean, here is a useful link:
///
/// https://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html
///
/// \param font the font to query.
/// \param ch the codepoto: c_int check.
/// \param minx a pointer filled in with the minimum x coordinate of the glyph
///             from the left edge of its bounding box. This value may be
///             negative.
/// \param maxx a pointer filled in with the maximum x coordinate of the glyph
///             from the left edge of its bounding box.
/// \param miny a pointer filled in with the minimum y coordinate of the glyph
///             from the bottom edge of its bounding box. This value may be
///             negative.
/// \param maxy a pointer filled in with the maximum y coordinate of the glyph
///             from the bottom edge of its bounding box.
/// \param advance a pointer filled in with the distance to the next glyph from
///                the left edge of this glyph's bounding box.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetGlyphMetrics(font: *Font, ch: u32, minx: *c_int, maxx: *c_int, miny: *c_int, maxy: *c_int, advance: *c_int) bool;

/// Query the kerning size between the glyphs of two UNICODE codepoints.
///
/// \param font the font to query.
/// \param previous_ch the previous codepoint.
/// \param ch the current codepoint.
/// \param kerning a pointer filled in with the kerning size between the two
///                glyphs, in pixels, may be NULL.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetGlyphKerning(font: *Font, previous_ch: u32, ch: u32, kerning: *c_int) bool;

/// Calculate the dimensions of a rendered string of UTF-8 text.
///
/// This will report the width and height, in pixels, of the space that the
/// specified string will take to fully render.
///
/// \param font the font to query.
/// \param text text to calculate, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param w will be filled with width, in pixels, on return.
/// \param h will be filled with height, in pixels, on return.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetStringSize(font: *Font, text: [*]const u8, length: usize, w: *c_int, h: *c_int) bool;

/// Calculate the dimensions of a rendered string of UTF-8 text.
///
/// This will report the width and height, in pixels, of the space that the
/// specified string will take to fully render.
///
/// Text is wrapped to multiple lines on line endings and on word boundaries if
/// it extends beyond `wrap_width` in pixels.
///
/// If wrap_width is 0, this function will only wrap on newline characters.
///
/// \param font the font to query.
/// \param text text to calculate, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param wrap_width the maximum width or 0 to wrap on newline characters.
/// \param w will be filled with width, in pixels, on return.
/// \param h will be filled with height, in pixels, on return.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetStringSizeWrapped(font: *Font, text: [*:0]const u8, length: usize, wrap_width: c_int, w: *c_int, h: *c_int) bool;

/// Calculate how much of a UTF-8 string will fit in a given width.
///
/// This reports the number of characters that can be rendered before reaching
/// `max_width`.
///
/// This does not need to render the string to do this calculation.
///
/// \param font the font to query.
/// \param text text to calculate, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param max_width maximum width, in pixels, available for the string, or 0
///                  for unbounded width.
/// \param measured_width a pointer filled in with the width, in pixels, of the
///                       string that will fit, may be NULL.
/// \param measured_length a pointer filled in with the length, in bytes, of
///                        the string that will fit, may be NULL.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_MeasureString(font: *Font, text: [*:0]const u8, length: usize, max_width: c_int, measured_width: *c_int, measured_length: *usize) bool;

/// Render UTF-8 text at fast quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's
/// 0 pixel will be the colorkey, giving a transparent background. The 1 pixel
/// will be set to the text color.
///
/// This will not word-wrap the string; you'll get a surface with a single line
/// of text, as long as the string requires. You can use
/// TTF_RenderText_Solid_Wrapped() instead if you need to wrap the output to
/// multiple lines.
///
/// This will not wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Shaded,
/// TTF_RenderText_Blended, and TTF_RenderText_LCD.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \returns a new 8-bit, palettized surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended
/// \sa TTF_RenderText_LCD
/// \sa TTF_RenderText_Shaded
/// \sa TTF_RenderText_Solid
/// \sa TTF_RenderText_Solid_Wrapped
////
extern fn TTF_RenderText_Solid(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color) ?*sdl.Surface;

/// Render word-wrapped UTF-8 text at fast quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's
/// 0 pixel will be the colorkey, giving a transparent background. The 1 pixel
/// will be set to the text color.
///
/// Text is wrapped to multiple lines on line endings and on word boundaries if
/// it extends beyond `wrapLength` in pixels.
///
/// If wrapLength is 0, this function will only wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Shaded_Wrapped,
/// TTF_RenderText_Blended_Wrapped, and TTF_RenderText_LCD_Wrapped.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \param wrapLength the maximum width of the text surface or 0 to wrap on
///                   newline characters.
/// \returns a new 8-bit, palettized surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended_Wrapped
/// \sa TTF_RenderText_LCD_Wrapped
/// \sa TTF_RenderText_Shaded_Wrapped
/// \sa TTF_RenderText_Solid
////
extern fn TTF_RenderText_Solid_Wrapped(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color, wrap_length: c_int) ?*sdl.Surface;

/// Render a single 32-bit glyph at fast quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's
/// 0 pixel will be the colorkey, giving a transparent background. The 1 pixel
/// will be set to the text color.
///
/// The glyph is rendered without any padding or centering in the X direction,
/// and aligned normally in the Y direction.
///
/// You can render at other quality levels with TTF_RenderGlyph_Shaded,
/// TTF_RenderGlyph_Blended, and TTF_RenderGlyph_LCD.
///
/// \param font the font to render with.
/// \param ch the character to render.
/// \param fg the foreground color for the text.
/// \returns a new 8-bit, palettized surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderGlyph_Blended
/// \sa TTF_RenderGlyph_LCD
/// \sa TTF_RenderGlyph_Shaded
////
extern fn TTF_RenderGlyph_Solid(font: *Font, ch: u32, fg: sdl.Color) ?*sdl.Surface;

/// Render UTF-8 text at high quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's
/// 0 pixel will be the specified background color, while other pixels have
/// varying degrees of the foreground color. This function returns the new
/// surface, or NULL if there was an error.
///
/// This will not word-wrap the string; you'll get a surface with a single line
/// of text, as long as the string requires. You can use
/// TTF_RenderText_Shaded_Wrapped() instead if you need to wrap the output to
/// multiple lines.
///
/// This will not wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Solid,
/// TTF_RenderText_Blended, and TTF_RenderText_LCD.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \param bg the background color for the text.
/// \returns a new 8-bit, palettized surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended
/// \sa TTF_RenderText_LCD
/// \sa TTF_RenderText_Shaded_Wrapped
/// \sa TTF_RenderText_Solid
////
extern fn TTF_RenderText_Shaded(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color, bg: sdl.Color) ?*sdl.Surface;

/// Render word-wrapped UTF-8 text at high quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's
/// 0 pixel will be the specified background color, while other pixels have
/// varying degrees of the foreground color. This function returns the new
/// surface, or NULL if there was an error.
///
/// Text is wrapped to multiple lines on line endings and on word boundaries if
/// it extends beyond `wrap_width` in pixels.
///
/// If wrap_width is 0, this function will only wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Solid_Wrapped,
/// TTF_RenderText_Blended_Wrapped, and TTF_RenderText_LCD_Wrapped.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \param bg the background color for the text.
/// \param wrap_width the maximum width of the text surface or 0 to wrap on
///                   newline characters.
/// \returns a new 8-bit, palettized surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended_Wrapped
/// \sa TTF_RenderText_LCD_Wrapped
/// \sa TTF_RenderText_Shaded
/// \sa TTF_RenderText_Solid_Wrapped
////
extern fn TTF_RenderText_Shaded_Wrapped(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color, bg: sdl.Color, wrap_width: c_int) ?*sdl.Surface;

/// Render a single UNICODE codepoat: c_int high quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's
/// 0 pixel will be the specified background color, while other pixels have
/// varying degrees of the foreground color. This function returns the new
/// surface, or NULL if there was an error.
///
/// The glyph is rendered without any padding or centering in the X direction,
/// and aligned normally in the Y direction.
///
/// You can render at other quality levels with TTF_RenderGlyph_Solid,
/// TTF_RenderGlyph_Blended, and TTF_RenderGlyph_LCD.
///
/// \param font the font to render with.
/// \param ch the codepoto: c_int render.
/// \param fg the foreground color for the text.
/// \param bg the background color for the text.
/// \returns a new 8-bit, palettized surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderGlyph_Blended
/// \sa TTF_RenderGlyph_LCD
/// \sa TTF_RenderGlyph_Solid
////
extern fn TTF_RenderGlyph_Shaded(font: *Font, ch: u32, fg: sdl.Color, bg: sdl.Color) ?*sdl.Surface;

/// Render UTF-8 text at high quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, using alpha
/// blending to dither the font with the given color. This function returns the
/// new surface, or NULL if there was an error.
///
/// This will not word-wrap the string; you'll get a surface with a single line
/// of text, as long as the string requires. You can use
/// TTF_RenderText_Blended_Wrapped() instead if you need to wrap the output to
/// multiple lines.
///
/// This will not wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Solid,
/// TTF_RenderText_Shaded, and TTF_RenderText_LCD.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \returns a new 32-bit, ARGB surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended_Wrapped
/// \sa TTF_RenderText_LCD
/// \sa TTF_RenderText_Shaded
/// \sa TTF_RenderText_Solid
////
extern fn TTF_RenderText_Blended(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color) ?*sdl.Surface;

/// Render word-wrapped UTF-8 text at high quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, using alpha
/// blending to dither the font with the given color. This function returns the
/// new surface, or NULL if there was an error.
///
/// Text is wrapped to multiple lines on line endings and on word boundaries if
/// it extends beyond `wrap_width` in pixels.
///
/// If wrap_width is 0, this function will only wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Solid_Wrapped,
/// TTF_RenderText_Shaded_Wrapped, and TTF_RenderText_LCD_Wrapped.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \param wrap_width the maximum width of the text surface or 0 to wrap on
///                   newline characters.
/// \returns a new 32-bit, ARGB surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended
/// \sa TTF_RenderText_LCD_Wrapped
/// \sa TTF_RenderText_Shaded_Wrapped
/// \sa TTF_RenderText_Solid_Wrapped
////
extern fn TTF_RenderText_Blended_Wrapped(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color, wrap_width: c_int) ?*sdl.Surface;

/// Render a single UNICODE codepoat: c_int high quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, using alpha
/// blending to dither the font with the given color. This function returns the
/// new surface, or NULL if there was an error.
///
/// The glyph is rendered without any padding or centering in the X direction,
/// and aligned normally in the Y direction.
///
/// You can render at other quality levels with TTF_RenderGlyph_Solid,
/// TTF_RenderGlyph_Shaded, and TTF_RenderGlyph_LCD.
///
/// \param font the font to render with.
/// \param ch the codepoto: c_int render.
/// \param fg the foreground color for the text.
/// \returns a new 32-bit, ARGB surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderGlyph_LCD
/// \sa TTF_RenderGlyph_Shaded
/// \sa TTF_RenderGlyph_Solid
////
extern fn TTF_RenderGlyph_Blended(font: *Font, ch: u32, fg: sdl.Color) ?*sdl.Surface;

/// Render UTF-8 text at LCD subpixel quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, and render
/// alpha-blended text using FreeType's LCD subpixel rendering. This function
/// returns the new surface, or NULL if there was an error.
///
/// This will not word-wrap the string; you'll get a surface with a single line
/// of text, as long as the string requires. You can use
/// TTF_RenderText_LCD_Wrapped() instead if you need to wrap the output to
/// multiple lines.
///
/// This will not wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Solid,
/// TTF_RenderText_Shaded, and TTF_RenderText_Blended.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \param bg the background color for the text.
/// \returns a new 32-bit, ARGB surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended
/// \sa TTF_RenderText_LCD_Wrapped
/// \sa TTF_RenderText_Shaded
/// \sa TTF_RenderText_Solid
////
extern fn TTF_RenderText_LCD(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color, bg: sdl.Color) ?*sdl.Surface;

/// Render word-wrapped UTF-8 text at LCD subpixel quality to a new ARGB
/// surface.
///
/// This function will allocate a new 32-bit, ARGB surface, and render
/// alpha-blended text using FreeType's LCD subpixel rendering. This function
/// returns the new surface, or NULL if there was an error.
///
/// Text is wrapped to multiple lines on line endings and on word boundaries if
/// it extends beyond `wrap_width` in pixels.
///
/// If wrap_width is 0, this function will only wrap on newline characters.
///
/// You can render at other quality levels with TTF_RenderText_Solid_Wrapped,
/// TTF_RenderText_Shaded_Wrapped, and TTF_RenderText_Blended_Wrapped.
///
/// \param font the font to render with.
/// \param text text to render, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \param fg the foreground color for the text.
/// \param bg the background color for the text.
/// \param wrap_width the maximum width of the text surface or 0 to wrap on
///                   newline characters.
/// \returns a new 32-bit, ARGB surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderText_Blended_Wrapped
/// \sa TTF_RenderText_LCD
/// \sa TTF_RenderText_Shaded_Wrapped
/// \sa TTF_RenderText_Solid_Wrapped
////
extern fn TTF_RenderText_LCD_Wrapped(font: *Font, text: [*:0]const u8, length: usize, fg: sdl.Color, bg: sdl.Color, wrap_width: c_int) ?*sdl.Surface;

/// Render a single UNICODE codepoat: c_int LCD subpixel quality to a new ARGB
/// surface.
///
/// This function will allocate a new 32-bit, ARGB surface, and render
/// alpha-blended text using FreeType's LCD subpixel rendering. This function
/// returns the new surface, or NULL if there was an error.
///
/// The glyph is rendered without any padding or centering in the X direction,
/// and aligned normally in the Y direction.
///
/// You can render at other quality levels with TTF_RenderGlyph_Solid,
/// TTF_RenderGlyph_Shaded, and TTF_RenderGlyph_Blended.
///
/// \param font the font to render with.
/// \param ch the codepoto: c_int render.
/// \param fg the foreground color for the text.
/// \param bg the background color for the text.
/// \returns a new 32-bit, ARGB surface, or NULL if there was an error.
///
/// \threadsafety This function should be called on the thread that created the
///               font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_RenderGlyph_Blended
/// \sa TTF_RenderGlyph_Shaded
/// \sa TTF_RenderGlyph_Solid
////
extern fn TTF_RenderGlyph_LCD(font: *Font, ch: u32, fg: sdl.Color, bg: sdl.Color) ?*sdl.Surface;

/// Internal data for TTF_Text
///
/// \since This struct is available since SDL_ttf 3.0.0.
////
pub const TextData = opaque {};

/// Text created with TTF_CreateText()
///
/// \since This struct is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateText
/// \sa TTF_GetTextProperties
/// \sa TTF_DestroyText
////
pub const Text = extern struct {
    /// A copy of the UTF-8 string that this text object represents,
    /// useful for layout, debugging and retrieving substring text.
    /// This is updated when the text object is modified and will
    /// be freed automatically when the object is destroyed.
    text: [*]u8,

    /// The number of lines in the text, 0 if it's empty
    num_lines: c_int,

    /// Application reference count, used when freeing surface
    refcount: c_int,

    /// Private
    internal: *TextData,

    pub const drawSurface = TTF_DrawSurfaceText;
    pub const drawRenderer = TTF_DrawRendererText;
    pub const gpuDrawData = TTF_GetGPUTextDrawData;
    pub const properties = TTF_GetTextProperties;
    pub const textEngineSet = TTF_SetTextEngine;
    pub const textEngine = TTF_GetTextEngine;
    pub const fontSet = TTF_SetTextFont;
    pub const font = TTF_GetTextFont;
    pub const directionSet = TTF_SetTextDirection;
    pub const direction = TTF_GetTextDirection;
    pub const scriptSet = TTF_SetTextScript;
    pub const script = TTF_GetTextScript;
    pub const colorSet = TTF_SetTextColor;
    pub const colorSetFloat = TTF_SetTextColorFloat;
    pub const color = TTF_GetTextColor;
    pub const colorFloat = TTF_GetTextColorFloat;
    pub const positionSet = TTF_SetTextPosition;
    pub const position = TTF_GetTextPosition;
    pub const wrapWidthSet = TTF_SetTextWrapWidth;
    pub const wrapWidth = TTF_GetTextWrapWidth;
    pub const wrapWhitespaceVisibleSet = TTF_SetTextWrapWhitespaceVisible;
    pub const wrapWhitespaceVisible = TTF_TextWrapWhitespaceVisible;
    pub const stringSet = TTF_SetTextString;
    pub const stringInsert = TTF_InsertTextString;
    pub const stringAppend = TTF_AppendTextString;
    pub const stringDelete = TTF_DeleteTextString;
    pub const size = TTF_GetTextSize;
    pub const subString = TTF_GetTextSubString;
    pub const subStringsForRange = TTF_GetTextSubStringsForRange;
    pub const subStringForPoint = TTF_GetTextSubStringForPoint;
    pub const subStringPrevious = TTF_GetPreviousTextSubString;
    pub const subStringNext = TTF_GetNextTextSubString;
    pub const update = TTF_UpdateText;
    pub const destroy = TTF_DestroyText;
};

/// Draw text to an SDL surface.
///
/// `text` must have been created using a TTF_TextEngine from
/// TTF_CreateSurfaceTextEngine().
///
/// \param text the text to draw.
/// \param x the x coordinate in pixels, positive from the left edge towards
///          the right.
/// \param y the y coordinate in pixels, positive from the top edge towards the
///          bottom.
/// \param surface the surface to draw on.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateSurfaceTextEngine
/// \sa TTF_CreateText
////
extern fn TTF_DrawSurfaceText(text: *Text, x: c_int, y: c_int, ?*sdl.Surface) bool;

/// Draw text to an SDL renderer.
///
/// `text` must have been created using a TTF_TextEngine from
/// TTF_CreateRendererTextEngine(), and will draw using the renderer passed to
/// that function.
///
/// \param text the text to draw.
/// \param x the x coordinate in pixels, positive from the left edge towards
///          the right.
/// \param y the y coordinate in pixels, positive from the top edge towards the
///          bottom.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateRendererTextEngine
/// \sa TTF_CreateText
////
extern fn TTF_DrawRendererText(text: *Text, x: f32, y: f32) bool;

/// Draw sequence returned by TTF_GetGPUTextDrawData
///
/// \since This struct is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetGPUTextDrawData
pub const GpuAtlasDrawSequence = extern struct {
    /// Texture atlas that stores the glyphs */
    atlas_texture: *sdl.gpu.Texture,

    /// An array of vertex positions */
    xy: [*]sdl.FPoint,

    /// An array of normalized texture coordinates for each vertex */
    uv: [*]sdl.FPoint,

    ///  Number of vertices */
    num_vertices: c_int,

    /// An array of indices into the 'vertices' arrays */
    indices: [*]c_int,

    /// Number of indices */
    num_indices: c_int,

    /// The image type of this draw sequence */
    image_type: ImageType,

    /// The next sequence (will be NULL in case of the last sequence) */
    next: ?*GpuAtlasDrawSequence,
};

/// Get the geometry data needed for drawing the text.
///
/// `text` must have been created using a TTF_TextEngine from
/// TTF_CreateGPUTextEngine().
///
/// The positive X-axis is taken towards the right and the positive Y-axis is
/// taken upwards for both the vertex and the texture coordinates, i.e, it
/// follows the same convention used by the SDL_GPU API. If you want to use a
/// different coordinate system you will need to transform the vertices
/// yourself.
///
/// If the text looks blocky use linear filtering.
///
/// \param text the text to draw.
/// \returns a NULL terminated linked list of TTF_GPUAtlasDrawSequence objects
///          or NULL if the passed text is empty or in case of failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateGPUTextEngine
/// \sa TTF_CreateText
////
extern fn TTF_GetGPUTextDrawData(text: *Text) ?*GpuAtlasDrawSequence;

/// Get the properties associated with a text object.
///
/// \param text the TTF_Text to query.
/// \returns a valid property ID on success or 0 on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextProperties(text: *Text) sdl.PropertiesID;

/// Set the text engine used by a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param engine the text engine to use for drawing.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextEngine
////
extern fn TTF_SetTextEngine(text: *Text, engine: *TextEngine) bool;

/// Get the text engine used by a text object.
///
/// \param text the TTF_Text to query.
/// \returns the TTF_TextEngine used by the text on success or NULL on failure;
///          call SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetTextEngine
////
extern fn TTF_GetTextEngine(text: *Text) ?*TextEngine;

/// Set the font used by a text object.
///
/// When a text object has a font, any changes to the font will automatically
/// regenerate the text. If you set the font to NULL, the text will continue to
/// render but changes to the font will no longer affect the text.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param font the font to use, may be NULL.
/// \returns false if the text pointer is null; otherwise, true. call
///          SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextFont
////
extern fn TTF_SetTextFont(text: *Text, font: *Font) bool;

/// Get the font used by a text object.
///
/// \param text the TTF_Text to query.
/// \returns the TTF_Font used by the text on success or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetTextFont
////
extern fn TTF_GetTextFont(text: *Text) ?*Font;

/// Set the direction to be used for text shaping a text object.
///
/// This function only supports left-to-right text shaping if SDL_ttf was not
/// built with HarfBuzz support.
///
/// \param text the text to modify.
/// \param direction the new direction for text to flow.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_SetTextDirection(text: *Text, direction: Direction) bool;

/// Get the direction to be used for text shaping a text object.
///
/// This defaults to the direction of the font used by the text object.
///
/// \param text the text to query.
/// \returns the direction to be used for text shaping.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextDirection(text: *Text) Direction;

/// Set the script to be used for text shaping a text object.
///
/// This returns false if SDL_ttf isn't built with HarfBuzz support.
///
/// \param text the text to modify.
/// \param script an
///               [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///               .
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_StringToTag
////
extern fn TTF_SetTextScript(text: *Text, script: u32) bool;

/// Get the script used for text shaping a text object.
///
/// This defaults to the script of the font used by the text object.
///
/// \param text the text to query.
/// \returns an
///          [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///          or 0 if a script hasn't been set on either the text object or the
///          font.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_TagToString
////
extern fn TTF_GetTextScript(text: *Text) u32;

/// Set the color of a text object.
///
/// The default text color is white (255, 255, 255, 255).
///
/// \param text the TTF_Text to modify.
/// \param r the red color value in the range of 0-255.
/// \param g the green color value in the range of 0-255.
/// \param b the blue color value in the range of 0-255.
/// \param a the alpha value in the range of 0-255.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextColor
/// \sa TTF_SetTextColorFloat
////
extern fn TTF_SetTextColor(text: *Text, r: u8, g: u8, b: u8, a: u8) bool;

/// Set the color of a text object.
///
/// The default text color is white (1.0f, 1.0f, 1.0f, 1.0f).
///
/// \param text the TTF_Text to modify.
/// \param r the red color value, normally in the range of 0-1.
/// \param g the green color value, normally in the range of 0-1.
/// \param b the blue color value, normally in the range of 0-1.
/// \param a the alpha value in the range of 0-1.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextColorFloat
/// \sa TTF_SetTextColor
////
extern fn TTF_SetTextColorFloat(text: *Text, r: f32, g: f32, b: f32, a: f32) bool;

/// Get the color of a text object.
///
/// \param text the TTF_Text to query.
/// \param r a pointer filled in with the red color value in the range of
///          0-255, may be NULL.
/// \param g a pointer filled in with the green color value in the range of
///          0-255, may be NULL.
/// \param b a pointer filled in with the blue color value in the range of
///          0-255, may be NULL.
/// \param a a pointer filled in with the alpha value in the range of 0-255,
///          may be NULL.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextColorFloat
/// \sa TTF_SetTextColor
////
extern fn TTF_GetTextColor(text: *Text, r: *u8, g: *u8, b: *u8, a: *u8) bool;

/// Get the color of a text object.
///
/// \param text the TTF_Text to query.
/// \param r a pointer filled in with the red color value, normally in the
///          range of 0-1, may be NULL.
/// \param g a pointer filled in with the green color value, normally in the
///          range of 0-1, may be NULL.
/// \param b a pointer filled in with the blue color value, normally in the
///          range of 0-1, may be NULL.
/// \param a a pointer filled in with the alpha value in the range of 0-1, may
///          be NULL.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextColor
/// \sa TTF_SetTextColorFloat
////
extern fn TTF_GetTextColorFloat(text: *Text, r: *f32, g: *f32, b: *f32, a: *f32) bool;

/// Set the position of a text object.
///
/// This can be used to position multiple text objects within a single wrapping
/// text area.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param x the x offset of the upper left corner of this text in pixels.
/// \param y the y offset of the upper left corner of this text in pixels.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextPosition
////
extern fn TTF_SetTextPosition(text: *Text, x: c_int, y: c_int) bool;

/// Get the position of a text object.
///
/// \param text the TTF_Text to query.
/// \param x a pointer filled in with the x offset of the upper left corner of
///          this text in pixels, may be NULL.
/// \param y a pointer filled in with the y offset of the upper left corner of
///          this text in pixels, may be NULL.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetTextPosition
////
extern fn TTF_GetTextPosition(text: *Text, x: *c_int, y: *c_int) bool;

/// Set whether wrapping is enabled on a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param wrap_width the maximum width in pixels, 0 to wrap on newline
///                   characters.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetTextWrapWidth
////
extern fn TTF_SetTextWrapWidth(text: *Text, wrap_width: c_int) bool;

/// Get whether wrapping is enabled on a text object.
///
/// \param text the TTF_Text to query.
/// \param wrap_width a pointer filled in with the maximum width in pixels or 0
///                   if the text is being wrapped on newline characters.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetTextWrapWidth
////
extern fn TTF_GetTextWrapWidth(text: *Text, wrap_width: *c_int) bool;

/// Set whether whitespace should be visible when wrapping a text object.
///
/// If the whitespace is visible, it will take up space for purposes of
/// alignment and wrapping. This is good for editing, but looks better when
/// centered or aligned if whitespace around line wrapping is hidden. This
/// defaults false.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param visible true to show whitespace when wrapping text, false to hide
///                it.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_TextWrapWhitespaceVisible
////
extern fn TTF_SetTextWrapWhitespaceVisible(text: *Text, visible: bool) bool;

/// Return whether whitespace is shown when wrapping a text object.
///
/// \param text the TTF_Text to query.
/// \returns true if whitespace is shown when wrapping text, or false
///          otherwise.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetTextWrapWhitespaceVisible
////
extern fn TTF_TextWrapWhitespaceVisible(text: *Text) bool;

/// Set the UTF-8 text used by a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param string the UTF-8 text to use, may be NULL.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_AppendTextString
/// \sa TTF_DeleteTextString
/// \sa TTF_InsertTextString
////
extern fn TTF_SetTextString(text: *Text, string: [*:0]const u8, length: usize) bool;

/// Insert UTF-8 text into a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param offset the offset, in bytes, from the beginning of the string if >=
///               0, the offset from the end of the string if < 0. Note that
///               this does not do UTF-8 validation, so you should only insert
///               at UTF-8 sequence boundaries.
/// \param string the UTF-8 text to insert.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_AppendTextString
/// \sa TTF_DeleteTextString
/// \sa TTF_SetTextString
////
extern fn TTF_InsertTextString(text: *Text, offset: c_int, string: [*:0]const u8, length: usize) bool;

/// Append UTF-8 text to a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param string the UTF-8 text to insert.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_DeleteTextString
/// \sa TTF_InsertTextString
/// \sa TTF_SetTextString
////
extern fn TTF_AppendTextString(text: *Text, string: [*:0]const u8, length: usize) bool;

/// Delete UTF-8 text from a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// \param text the TTF_Text to modify.
/// \param offset the offset, in bytes, from the beginning of the string if >=
///               0, the offset from the end of the string if < 0. Note that
///               this does not do UTF-8 validation, so you should only delete
///               at UTF-8 sequence boundaries.
/// \param length the length of text to delete, in bytes, or -1 for the
///               remainder of the string.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_AppendTextString
/// \sa TTF_InsertTextString
/// \sa TTF_SetTextString
////
extern fn TTF_DeleteTextString(text: *Text, offset: c_int, length: c_int) bool;

/// Get the size of a text object.
///
/// The size of the text may change when the font or font style and size
/// change.
///
/// \param text the TTF_Text to query.
/// \param w a pointer filled in with the width of the text, in pixels, may be
///          NULL.
/// \param h a pointer filled in with the height of the text, in pixels, may be
///          NULL.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextSize(text: *Text, w: *c_int, h: *c_int) bool;

/// Flags for TTF_SubString
///
/// \since This datatype is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SubString
////
pub const SubStringFlags = packed struct(u32) {
    direction_mask: u8 = 0,
    text_start: bool = false,
    line_start: bool = false,
    line_end: bool = false,
    text_end: bool = false,
    padding: u20 = 0,
};

/// The representation of a substring within text.
///
/// \since This struct is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetNextTextSubString
/// \sa TTF_GetPreviousTextSubString
/// \sa TTF_GetTextSubString
/// \sa TTF_GetTextSubStringForLine
/// \sa TTF_GetTextSubStringForPoint
/// \sa TTF_GetTextSubStringsForRange
pub const SubString = extern struct {
    /// The flags for this substring */
    flags: SubStringFlags,

    /// The byte offset from the beginning of the text */
    offset: c_int,

    /// The byte length starting at the offset */
    length: c_int,

    /// The index of the line that contains this substring */
    line_index: c_int,

    /// The internal cluster index, used for quickly iterating */
    cluster_index: c_int,

    /// The rectangle, relative to the top left of the text, containing the substring */
    rect: sdl.Rect,
};

/// Get the substring of a text object that surrounds a text offset.
///
/// If `offset` is less than 0, this will return a zero length substring at the
/// beginning of the text with the TTF_SUBSTRING_TEXT_START flag set. If
/// `offset` is greater than or equal to the length of the text string, this
/// will return a zero length substring at the end of the text with the
/// TTF_SUBSTRING_TEXT_END flag set.
///
/// \param text the TTF_Text to query.
/// \param offset a byte offset into the text string.
/// \param substring a pointer filled in with the substring containing the
///                  offset.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextSubString(text: *Text, offset: c_int, substring: *SubString) bool;

/// Get the substring of a text object that contains the given line.
///
/// If `line` is less than 0, this will return a zero length substring at the
/// beginning of the text with the TTF_SUBSTRING_TEXT_START flag set. If `line`
/// is greater than or equal to `text->num_lines` this will return a zero
/// length substring at the end of the text with the TTF_SUBSTRING_TEXT_END
/// flag set.
///
/// \param text the TTF_Text to query.
/// \param line a zero-based line index, in the range [0 .. text->num_lines-1].
/// \param substring a pointer filled in with the substring containing the
///                  offset.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextSubStringForLine(text: *Text, line: c_int, substring: *SubString) bool;

/// Get the substrings of a text object that contain a range of text.
///
/// \param text the TTF_Text to query.
/// \param offset a byte offset into the text string.
/// \param length the length of the range being queried, in bytes, or -1 for
///               the remainder of the string.
/// \param count a pointer filled in with the number of substrings returned,
///              may be NULL.
/// \returns a NULL terminated array of substring pointers or NULL on failure;
///          call SDL_GetError() for more information. This is a single
///          allocation that should be freed with SDL_free() when it is no
///          longer needed.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextSubStringsForRange(text: *Text, offset: c_int, length: c_int, count: *c_int) [*:null]SubString;

/// Get the portion of a text string that is closest to a point.
///
/// This will return the closest substring of text to the given point.
///
/// \param text the TTF_Text to query.
/// \param x the x coordinate relative to the left side of the text, may be
///          outside the bounds of the text area.
/// \param y the y coordinate relative to the top side of the text, may be
///          outside the bounds of the text area.
/// \param substring a pointer filled in with the closest substring of text to
///                  the given point.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetTextSubStringForPoint(text: *Text, x: c_int, y: c_int, substring: *SubString) bool;

/// Get the previous substring in a text object
///
/// If called at the start of the text, this will return a zero length
/// substring with the TTF_SUBSTRING_TEXT_START flag set.
///
/// \param text the TTF_Text to query.
/// \param substring the TTF_SubString to query.
/// \param previous a pointer filled in with the previous substring in the text
///                 object.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetPreviousTextSubString(text: *Text, substring: *SubString, previous: *SubString) bool;

/// Get the next substring in a text object
///
/// If called at the end of the text, this will return a zero length substring
/// with the TTF_SUBSTRING_TEXT_END flag set.
///
/// \param text the TTF_Text to query.
/// \param substring the TTF_SubString to query.
/// \param next a pointer filled in with the next substring.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_GetNextTextSubString(text: *Text, substring: *const SubString, next: *SubString) bool;

/// Update the layout of a text object.
///
/// This is automatically done when the layout is requested or the text is
/// rendered, but you can call this if you need more control over the timing of
/// when the layout and text engine representation are updated.
///
/// \param text the TTF_Text to update.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_UpdateText(text: *Text) bool;

/// Destroy a text object created by a text engine.
///
/// \param text the text to destroy.
///
/// \threadsafety This function should be called on the thread that created the
///               text.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateText
////
extern fn TTF_DestroyText(text: *Text) void;

/// Dispose of a previously-created font.
///
/// Call this when done with a font. This function will free any resources
/// associated with it. It is safe to call this function on NULL, for example
/// on the result of a failed call to TTF_OpenFont().
///
/// The font is not valid after being passed to this function. String pointers
/// from functions that return information on this font, such as
/// TTF_GetFontFamilyName() and TTF_GetFontStyleName(), are no longer valid
/// after this call, as well.
///
/// \param font the font to dispose of.
///
/// \threadsafety This function should not be called while any other thread is
///               using the font.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_OpenFont
/// \sa TTF_OpenFontIO
////
extern fn TTF_CloseFont(font: *Font) void;

/// Deinitialize SDL_ttf.
///
/// You must call this when done with the library, to free internal resources.
/// It is safe to call this when the library isn't initialized, as it will just
/// return immediately.
///
/// Once you have as many quit calls as you have had successful calls to
/// TTF_Init, the library will actually deinitialize.
///
/// Please note that this does not automatically close any fonts that are still
/// open at the time of deinitialization, and it is possibly not safe to close
/// them afterwards, as parts of the library will no longer be initialized to
/// deal with it. A well-written program should call TTF_CloseFont() on any
/// open fonts before calling this function!
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
////
extern fn TTF_Quit() void;

/// Check if SDL_ttf is initialized.
///
/// This reports the number of times the library has been initialized by a call
/// to TTF_Init(), without a paired deinitialization request from TTF_Quit().
///
/// In short: if it's greater than zero, the library is currently initialized
/// and ready to work. If zero, it is not initialized.
///
/// Despite the return value being a signed integer, this function should not
/// return a negative number.
///
/// \returns the current number of initialization calls, that need to
///          eventually be paired with this many calls to TTF_Quit().
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_Init
/// \sa TTF_Quit
////
extern fn TTF_WasInit() c_int;
