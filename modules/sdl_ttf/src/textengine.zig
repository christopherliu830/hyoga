/// SDL_ttf:  A companion library to SDL for working with TrueType (tm) fonts
/// Copyright (C) 2001-2025 Sam Lantinga <slouken@libsdl.org>
///
/// This software is provided 'as-is', without any express or implied
/// warranty.  In no event will the authors be held liable for any damages
/// arising from the use of this software.
///
/// Permission is granted to anyone to use this software for any purpose,
/// including commercial applications, and to alter it and redistribute it
/// freely, subject to the following restrictions:
///
/// 1. The origin of this software must not be misrepresented; you must not
///    claim that you wrote the original software. If you use this software
///    in a product, an acknowledgment in the product documentation would be
///    appreciated but is not required.
/// 2. Altered source versions must be plainly marked as such, and must not be
///    misrepresented as being the original software.
/// 3. This notice may not be removed or altered from any source distribution.
const std = @import("std");
const sdl = @import("sdl");
const ttf = @import("root.zig");

const Text = ttf.Text;
const Font = ttf.Font;
const SubString = ttf.SubString;

///  A font atlas draw command.
///
///  \since This enum is available since SDL_ttf 3.0.0.
pub const DrawCommand = enum(c_int) { noop, fill, copy };

/// A filled rectangle draw operation.
///
/// \since This struct is available since SDL_ttf 3.0.0.
///
/// \sa TTF_DrawOperation
pub const FillOperation = extern struct {
    cmd: DrawCommand, //*< TTF_DRAW_COMMAND_FILL */
    rect: sdl.Rect, //*< The rectangle to fill, in pixels. The x coordinate is relative to the left side of the text area, going right, and the y coordinate is relative to the top side of the text area, going down. */
};

/// A texture copy draw operation.
///
/// \since This struct is available since SDL_ttf 3.0.0.
///
/// \sa TTF_DrawOperation
pub const CopyOperation = extern struct {
    cmd: DrawCommand, // TTF_DRAW_COMMAND_COPY */
    text_offset: c_int, // The offset in the text corresponding to this glyph.
    //  There may be multiple glyphs with the same text offset
    //  and the next text offset might be several Unicode codepoints
    //  later. In this case the glyphs and codepoints are grouped
    //  together and the group bounding box is the union of the dst
    //  rectangles for the corresponding glyphs.
    glyph_font: *Font, // The font containing the glyph to be drawn, can be passed to TTF_GetGlyphImageForIndex()
    glyph_index: u32, // The glyph index of the glyph to be drawn, can be passed to TTF_GetGlyphImageForIndex()
    src: sdl.Rect, // The area within the glyph to be drawn
    dst: sdl.Rect, // The drawing coordinates of the glyph, in pixels. The x coordinate is relative to the
    // left side of the text area, going right, and the y coordinate is relative to the top side of the text area, going down.
    reserved: ?*anyopaque,
};

///  A text engine draw operation.
///
///  \since This struct is available since SDL_ttf 3.0.0.
pub const DrawOperation = extern union {
    cmd: DrawCommand,
    fill: FillOperation,
    copy: CopyOperation,
};

/// Private data in TTF_Text, to assist in text measurement and layout */
pub const TextLayout = opaque {};

/// Private data in TTF_Text, available to implementations */
pub const TextData = extern struct {
    font: *Font, //*< The font used by this text, read-only. */
    color: sdl.FColor, //*< The color of the text, read-only. */

    needs_layout_update: bool, //*< True if the layout needs to be updated */
    layout: *TextLayout, //*< Cached layout information, read-only. */
    x: c_int, //*< The x offset of the upper left corner of this text, in pixels, read-only. */
    y: c_int, //*< The y offset of the upper left corner of this text, in pixels, read-only. */
    w: c_int, //*< The width of this text, in pixels, read-only. */
    h: c_int, //*< The height of this text, in pixels, read-only. */
    num_ops: c_int, //*< The number of drawing operations to render this text, read-only. */
    ops: [*]DrawOperation, //*< The drawing operations used to render this text, read-only. */
    num_clusters: c_int, //*< The number of substrings representing clusters of glyphs in the string, read-only */
    clusters: [*]SubString, //*< Substrings representing clusters of glyphs in the string, read-only */

    props: sdl.PropertiesID, //*< Custom properties associated with this text, read-only. This field is created as-needed using TTF_GetTextProperties() and the properties may be then set and read normally */

    needs_engine_update: bool, //*< True if the engine text needs to be updated */
    engine: *TextEngine, //*< The engine used to render this text, read-only. */
    engine_text: ?*anyopaque, //*< The implementation-specific representation of this text */
};

/// A text engine interface.
///
/// This structure should be initialized using SDL_INIT_INTERFACE()
///
/// \since This struct is available since SDL_ttf 3.0.0.
///
/// \sa SDL_INIT_INTERFACE
pub const TextEngine = extern struct {
    version: u32,
    userdata: ?*anyopaque,

    /// Create a text representation from draw instructions.
    ///
    /// All fields of `text` except `internal->engine_text` will already be filled out.
    ///
    /// This function should set the `internal->engine_text` field to a non-NULL value.
    ///
    /// \param userdata the userdata pointer in this interface.
    /// \param text the text object being created.
    createText: *const fn (userdata: ?*anyopaque, text: *Text) callconv(.c) bool,

    /// Destroy a text representation.
    destroyText: *const fn (userdata: ?*anyopaque, text: *Text) callconv(.c) void,

    const rendererCreate = TTF_CreateRendererTextEngine;
    const rendererCreateWithProperties = TTF_CreateRendererTextEngineWithProperties;
    const rendererDestroy = TTF_DestroyRendererTextEngine;
    pub const surfaceCreate = TTF_CreateSurfaceTextEngine;
    pub const surfaceDestroy = TTF_DestroySurfaceTextEngine;
    pub const gpuCreate = TTF_CreateGPUTextEngine;
    pub const gpuCreateWithProperties = TTF_CreateGPUTextEngineWithProperties;
    pub const gpuDestroy = TTF_DestroyGPUTextEngine;
    pub const gpuWindingSet = TTF_SetGPUTextEngineWinding;
    pub const gpuWinding = TTF_GetGPUTextEngineWinding;
    pub const textCreate = TTF_CreateText;
};

/// Create a text engine for drawing text on SDL surfaces.
///
/// \returns a TTF_TextEngine object or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_DestroySurfaceTextEngine
/// \sa TTF_DrawSurfaceText
extern fn TTF_CreateSurfaceTextEngine() ?*TextEngine;

/// Destroy a text engine created for drawing text on SDL surfaces.
///
/// All text created by this engine should be destroyed before calling this
/// function.
///
/// \param engine a TTF_TextEngine object created with
///               TTF_CreateSurfaceTextEngine().
///
/// \threadsafety This function should be called on the thread that created the
///               engine.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateSurfaceTextEngine
extern fn TTF_DestroySurfaceTextEngine(engine: *TextEngine) void;

/// Create a text engine for drawing text on an SDL renderer.
///
/// \param renderer the renderer to use for creating textures and drawing text.
/// \returns a TTF_TextEngine object or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               renderer.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_DestroyRendererTextEngine
/// \sa TTF_DrawRendererText
/// \sa TTF_CreateRendererTextEngineWithProperties
const Renderer = opaque {};
extern fn TTF_CreateRendererTextEngine(renderer: *Renderer) ?*TextEngine;

/// Create a text engine for drawing text on an SDL renderer, with the
/// specified properties.
///
/// These are the supported properties:
///
/// - `TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER_POINTER`: the renderer to use for
///   creating textures and drawing text
/// - `TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE_NUMBER`: the size of
///   the texture atlas
///
/// \param props the properties to use.
/// \returns a TTF_TextEngine object or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               renderer.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateRendererTextEngine
/// \sa TTF_DestroyRendererTextEngine
/// \sa TTF_DrawRendererText
extern fn TTF_CreateRendererTextEngineWithProperties(props: sdl.PropertiesID) ?*TextEngine;

/// Destroy a text engine created for drawing text on an SDL renderer.
///
/// All text created by this engine should be destroyed before calling this
/// function.
///
/// \param engine a TTF_TextEngine object created with
///               TTF_CreateRendererTextEngine().
///
/// \threadsafety This function should be called on the thread that created the
///               engine.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateRendererTextEngine
extern fn TTF_DestroyRendererTextEngine(engine: *TextEngine) void;

/// Create a text engine for drawing text with the SDL GPU API.
///
/// \param device the SDL_GPUDevice to use for creating textures and drawing
///               text.
/// \returns a TTF_TextEngine object or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               device.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateGPUTextEngineWithProperties
/// \sa TTF_DestroyGPUTextEngine
/// \sa TTF_GetGPUTextDrawData
extern fn TTF_CreateGPUTextEngine(device: *sdl.gpu.Device) ?*TextEngine;

/// Create a text engine for drawing text with the SDL GPU API, with the
/// specified properties.
///
/// These are the supported properties:
///
/// - `TTF_PROP_GPU_TEXT_ENGINE_DEVICE_POINTER`: the SDL_GPUDevice to use for
///   creating textures and drawing text.
/// - `TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE_NUMBER`: the size of the
///   texture atlas
///
/// \param props the properties to use.
/// \returns a TTF_TextEngine object or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \threadsafety This function should be called on the thread that created the
///               device.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateGPUTextEngine
/// \sa TTF_DestroyGPUTextEngine
/// \sa TTF_GetGPUTextDrawData
extern fn TTF_CreateGPUTextEngineWithProperties(props: sdl.PropertiesID) ?*TextEngine;

/// The winding order of the vertices returned by TTF_GetGPUTextDrawData
///
/// \since This enum is available since SDL_ttf 3.0.0.
pub const GpuTextEngineWinding = enum(c_int) {
    invalid = -1,
    clockwise,
    counter_clockwise,
};

/// Sets the winding order of the vertices returned by TTF_GetGPUTextDrawData
/// for a particular GPU text engine.
///
/// \param engine a TTF_TextEngine object created with
///               TTF_CreateGPUTextEngine().
/// \param winding the new winding order option.
///
/// \threadsafety This function should be called on the thread that created the
///               engine.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_GetGPUTextEngineWinding
////
extern fn TTF_SetGPUTextEngineWinding(engine: *TextEngine, winding: GpuTextEngineWinding) void;

/// Get the winding order of the vertices returned by TTF_GetGPUTextDrawData
/// for a particular GPU text engine
///
/// \param engine a TTF_TextEngine object created with
///               TTF_CreateGPUTextEngine().
/// \returns the winding order used by the GPU text engine or
///          TTF_GPU_TEXTENGINE_WINDING_INVALID in case of error.
///
/// \threadsafety This function should be called on the thread that created the
///               engine.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_SetGPUTextEngineWinding
////
extern fn TTF_GetGPUTextEngineWinding(engine: *const TextEngine) GpuTextEngineWinding;

/// Destroy a text engine created for drawing text with the SDL GPU API.
///
/// All text created by this engine should be destroyed before calling this
/// function.
///
/// \param engine a TTF_TextEngine object created with
///               TTF_CreateGPUTextEngine().
///
/// \threadsafety This function should be called on the thread that created the
///               engine.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_CreateGPUTextEngine
////
extern fn TTF_DestroyGPUTextEngine(engine: *TextEngine) void;

/// Create a text object from UTF-8 text and a text engine.
///
/// \param engine the text engine to use when creating the text object, may be
///               NULL.
/// \param font the font to render with.
/// \param text the text to use, in UTF-8 encoding.
/// \param length the length of the text, in bytes, or 0 for null terminated
///               text.
/// \returns a TTF_Text object or NULL on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should be called on the thread that created the
///               font and text engine.
///
/// \since This function is available since SDL_ttf 3.0.0.
///
/// \sa TTF_DestroyText
////
extern fn TTF_CreateText(engine: *TextEngine, font: *Font, text: [*]const u8, length: usize) ?*Text;

comptime {
    std.debug.assert(@sizeOf(?*anyopaque) == 4 and @sizeOf(TextEngine) == 16 or
        @sizeOf(?*anyopaque) == 8 and @sizeOf(TextEngine) == 32);
}
