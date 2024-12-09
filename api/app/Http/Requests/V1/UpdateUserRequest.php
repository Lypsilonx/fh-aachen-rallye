<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();

        if ($user === null) {
            return false;
        }

        return $user->tokenCan('update:users') || ($user->tokenCan('update:users:self') && $user->id === $this->route('user')->id);
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $method = $this->method();

        if ($method === 'PUT') {
            return [
                'username' => ['required', 'string', 'max:255'],
                'displayName' => ['string', 'nullable'],
            ];
        } else {
            return [
                'username' => ['sometimes', 'required', 'string', 'max:255'],
                'displayName' => ['sometimes', 'string', 'nullable'],
            ];
        }
    }
}
