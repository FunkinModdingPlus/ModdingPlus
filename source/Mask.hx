package;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
#if !macro
@:genericBuild(MaskMacro.buildTypeDef())
#end
/**
 * Transforms a typedef into a mask (meaning every field becomes a bool)
 */
class Mask<T> {}
@:dce
class MaskMacro
{
	#if macro
	static var cache:Map<String, ComplexType> = new Map();

	static function buildTypeDef()
	{
		var localType = Context.getLocalType();
		var cacheKey = TypeTools.toString(localType);
		if (cache.exists(cacheKey))
			return cache.get(cacheKey);

		switch (localType)
		{
			// Match when class's type parameter leads to an anonymous type (we convert to a complex type in the process to make it easier to work with)
			case TInst(_, [
				Context.followWithAbstracts(_) => TypeTools.toComplexType(_) => TAnonymous(fields)
			]):
				// Add @:optional meta to all fields
				var newFields = fields.map(addMeta);
				var ret = TAnonymous(newFields);
				cache.set(cacheKey, ret);
				return ret;

			default:
				Context.fatalError('Type parameter should be an anonymous structure', Context.currentPos());
		}

		return null;
	}

	static function addMeta(field:Field):Field
	{
		// Handle Null<T> and optional fields already parsed by the compiler
		var kind = switch (field.kind)
		{
			case FVar(_, write):
				FVar(macro :Null<Bool>, write);

			default:
				field.kind;
		}

		return {
			name: field.name,
			kind: kind,
			access: field.access,
			meta: field.meta,
			pos: field.pos
		};
	}
	#end
}